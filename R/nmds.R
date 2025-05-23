#' Non-Metric Dimensional Scaling
#'
#' An S4 Class implementing Non-Metric Dimensional Scaling.
#'
#' A non-linear extension of MDS using monotonic regression
#'
#' @template dimRedMethodSlots
#'
#' @template dimRedMethodGeneralUsage
#'
#' @section Parameters:
#' nMDS can take the following parameters:
#' \describe{
#'   \item{d}{A distance function.}
#'   \item{ndim}{The number of embedding dimensions.}
#' }
#'
#' @section Implementation:
#' Wraps around the
#' \code{\link[vegan]{monoMDS}}. For parameters that are not
#' available here, the standard configuration is used.
#'
#' @references
#'
#' Kruskal, J.B., 1964. Nonmetric multidimensional scaling: A numerical method.
#' Psychometrika 29, 115-129. https://doi.org/10.1007/BF02289694
#'
#' @examples
#' if(requireNamespace("vegan", quietly = TRUE)) {
#'
#' dat <- loadDataSet("3D S Curve", n = 300)
#' emb <- embed(dat, "nMDS")
#' plot(emb, type = "2vars")
#'
#' }
#' @include dimRedResult-class.R
#' @include dimRedMethod-class.R
#' @family dimensionality reduction methods
#' @export nMDS
#' @exportClass nMDS
nMDS <- setClass(
    "nMDS",
    contains = "dimRedMethod",
    prototype = list(
        stdpars = list(d = stats::dist, ndim = 2),
        fun = function (data, pars,
                        keep.org.data = TRUE) {
        chckpkg("vegan")

        meta <- data@meta
        orgdata <- if (keep.org.data) data@data else matrix(0, 0, 0)
        indata <- data@data

        outdata <- vegan::monoMDS(pars$d(indata), k = pars$ndim)$points

        colnames(outdata) <- paste0("NMDS", 1:ncol(outdata))

        return(new(
            "dimRedResult",
            data         = new("dimRedData",
                               data = outdata,
                               meta = meta),
            org.data     = orgdata,
            has.org.data = keep.org.data,
            method       = "nmds",
            pars         = pars
        ))
        },
      requires = c("vegan"))
)
