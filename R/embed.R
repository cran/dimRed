#' dispatches the different methods for dimensionality reduction
#'
#' wraps around all dimensionality reduction functions.
#'
#' Method must be one of \code{\link{dimRedMethodList}()}, partial matching
#' is performed. All parameters start with a dot, to avoid clashes
#' with partial argument matching (see the R manual section 4.3.2), if
#' there should ever occur any clashes in the arguments, call the
#' function with all arguments named, e.g. \code{embed(.data = dat,
#' .method = "mymethod", .d = "some parameter")}.
#'
#' @param .data object of class \code{\link{dimRedData}}, will be converted to
#'   be of class \code{\link{dimRedData}} if necessary; see examples for
#'   details.
#' @param .method character vector naming one of the dimensionality reduction
#'   techniques.
#' @param .mute a character vector containing the elements you want to mute
#'   (\code{c("message", "output")}), defaults to \code{character(0)}.
#' @param .keep.org.data \code{TRUE}/\code{FALSE} keep the original data.
#' @param ... the parameters, internally passed as a list to the dimensionality
#'   reduction method as \code{pars = list(...)}
#' @return an object of class \code{\link{dimRedResult}}
#'
#' @examples
#' ## embed a data.frame using a formula:
#' as.data.frame(
#'   embed(Species ~ Sepal.Length + Sepal.Width + Petal.Length + Petal.Width,
#'         iris, "PCA")
#' )
#'
#' ## embed a data.frame and return a data.frame
#' as.data.frame(embed(iris[, 1:4], "PCA"))
#'
#' ## embed a matrix and return a data.frame
#' as.data.frame(embed(as.matrix(iris[, 1:4]), "PCA"))
#'
#' \dontrun{
#' ## embed dimRedData objects
#' embed_methods <- dimRedMethodList()
#' quality_methods <- dimRedQualityList()
#' dataset <- loadDataSet("Iris")
#'
#' quality_results <- matrix(NA, length(embed_methods), length(quality_methods),
#'                               dimnames = list(embed_methods, quality_methods))
#' embedded_data <- list()
#'
#' for (e in embed_methods) {
#'   message("embedding: ", e)
#'   embedded_data[[e]] <- embed(dataset, e, .mute = c("message", "output"))
#'   for (q in quality_methods) {
#'     message("  quality: ", q)
#'     quality_results[e, q] <- tryCatch(
#'       quality(embedded_data[[e]], q),
#'       error = function(e) NA
#'     )
#'   }
#' }
#'
#' print(quality_results)
#' }
#' @export
setGeneric("embed", function(.data, ...) standardGeneric("embed"),
           valueClass = "dimRedResult")

#' @describeIn embed embed a data.frame using a formula.
#' @param .formula a formula, see \code{\link{as.dimRedData}}.
#' @export
setMethod(
    "embed",
    "formula",
    function(.formula, .data, .method = dimRedMethodList(),
             .mute = character(0), .keep.org.data = TRUE,
             ...) {
        if (!is.data.frame(.data)) stop(".data must be a data.frame")

        .data <- as.dimRedData(.formula, .data)
        embed(.data, .method, .mute, .keep.org.data, ...)
    }
)

#' @describeIn embed Embed anything as long as it can be coerced to
#'     \code{\link{dimRedData}}.
#' @export
setMethod(
    "embed",
    "ANY",
    function(.data, .method = dimRedMethodList(),
             .mute = character(0), .keep.org.data = TRUE,
             ...) {
        embed(as(.data, "dimRedData"), .method, .mute, .keep.org.data, ...)
    }
)

#' @describeIn embed Embed a dimRedData object
#' @export
setMethod(
    "embed",
    "dimRedData",
    function(.data, .method = dimRedMethodList(),
             .mute = character(0), #c("message", "output"),
             .keep.org.data = TRUE,
             ...) {
      .method <- if (all(.method == dimRedMethodList())) "PCA"
                 else match.arg(.method)

        methodObject <- getMethodObject(.method)

        args <- list(
            data          = as(.data, "dimRedData"),
            keep.org.data = .keep.org.data
        )
        args$pars <- matchPars(methodObject, list(...))

        devnull <- if (Sys.info()["sysname"] != "Windows")
                       "/dev/null"
                   else
                       "NUL"
        if ("message" %in% .mute){
            devnull1 <- file(devnull,  "wt")
            sink(devnull1, type = "message")
            on.exit({
                sink(file = NULL, type = "message")
                close(devnull1)
            }, add = TRUE)
        }
        if ("output" %in% .mute) {
            devnull2 <- file(devnull,  "wt")
            sink(devnull2, type = "output")
            on.exit({
                sink()
                close(devnull2)
            }, add = TRUE)
        }

        do.call(methodObject@fun, args)
    }
)

getMethodObject <- function (method) {
    ## switch(
    ##     method,
    ##     graph_kk  = kamada_kawai,
    ##     graph_drl = drl,
    ##     graph_fr  = fruchterman_reingold,
    ##     drr       = drr,
    ##     isomap    = isomap,
    ##     diffmap   = diffmap,
    ##     tsne      = tsne,
    ##     nmds      = nmds,
    ##     mds       = mds,
    ##     ica       = fastica,
    ##     pca       = pca,
    ##     lle       = lle,
    ##     loe       = loe,
    ##     soe       = soe,
    ##     leim      = leim,
    ##     kpca      = kpca
    ## )
    method <- match.arg(method, dimRedMethodList())
    do.call(method, list())
}

