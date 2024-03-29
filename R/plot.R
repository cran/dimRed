#' Plotting of dimRed* objects
#'
#' Plots a object of class dimRedResult and dimRedData. For the
#' documentation of the plotting function in base see here:
#' \code{\link{plot.default}}.
#'
#' Plotting functions for the classes usind in \code{dimRed}. they are
#' intended to give a quick overview over the results, so they are
#' somewhat inflexible, e.g. it is hard to modify color scales or
#' plotting parameters.
#'
#' If you require more control over plotting, it is better to convert
#' the object to a \code{data.frame} first and use the standard
#' functions for plotting.
#'
#' @param x dimRedResult/dimRedData class, e.g. output of
#'     embedded/loadDataSet
#' @param y Ignored
#' @param type plot type, one of \code{c("pairs", "parpl", "2vars",
#'     "3vars", "3varsrgl")}
#' @param col the columns of the meta slot to use for coloring, can be
#'     referenced as the column names or number of x@data
#' @param vars the axes of the embedding to use for plotting
#' @param ... handed over to the underlying plotting function.
#'
#' @examples
#' scurve = loadDataSet("3D S Curve")
#' if(requireNamespace("graphics", quietly = TRUE))
#'   plot(scurve, type = "pairs", main = "pairs plot of S curve")
#' if(requireNamespace("MASS", quietly = TRUE))
#'   plot(scurve, type = "parpl")
#' if(requireNamespace("graphics", quietly = TRUE))
#'   plot(scurve, type = "2vars", vars = c("y", "z"))
#' if(requireNamespace("scatterplot3d", quietly = TRUE))
#'   plot(scurve, type = "3vars")
#' if(requireNamespace("rgl", quietly = TRUE))
#'   plot(scurve, type = "3varsrgl")
#'
#' @include mixColorSpaces.R
#' @include dimRedData-class.R
#' @importFrom graphics plot
#'
#' @aliases plot.dimRed
#' @export
setGeneric(
    "plot", function(x, y, ...) standardGeneric("plot"),
    useAsDefault = graphics::plot
)

#' @describeIn plot Ploting of dimRedData objects
#' @aliases plot.dimRedData
#' @export
setMethod(
    f = "plot",
    signature = c("dimRedData"),
    definition = function(x, type = "pairs",
                          vars = seq_len(ncol(x@data)),
                          col = seq_len(min(3, ncol(x@meta))), ...) {
        cols <- colorize(x@meta[, col, drop = FALSE])
        switch(
            type,
            "pairs"    = {
                chckpkg("graphics")
                graphics::pairs(x@data[, vars],      col = cols,   ... )
            },
            "parpl"    = {
                chckpkg("MASS")
                MASS::parcoord(x@data[, vars],      col = cols,   ... )
            },
            "2vars"    = {
                chckpkg("graphics")
                graphics::plot(x@data[, vars[1:2]], col = cols,   ... )
            },
            "3vars"    = {
                chckpkg("scatterplot3d")
                scatterplot3d::scatterplot3d(x@data[, vars[1:3]],
                                             color = cols,
                                             ...)
            },
            "3varsrgl" = {
                chckpkg("rgl")
                rgl::plot3d(x@data[, vars[1:3]], col = cols,   ... )
            },
            stop("wrong argument to plot.dimRedData")
        )
    }
)


#' @describeIn plot Ploting of dimRedResult objects.
#' @aliases plot.dimRedResult
#' @export
setMethod(
    f = "plot",
    signature = c("dimRedResult"),
    definition = function (x, type = "pairs",
                           vars = seq_len(ncol(x@data@data)),
                           col = seq_len(min(3, ncol(x@data@meta))), ...) {
        plot(x = x@data, type = type, vars = vars, col = col, ...)
    }
)

#' plot_R_NX
#'
#' Plot the R_NX curve for different embeddings. Takes a list of
#' \code{\link{dimRedResult}} objects as input.
#' Also the Area under the curve values are computed for a weighted K
#' (see \link{AUC_lnK_R_NX} for details) and appear in the legend.
#'
#' @param x a list of \code{\link{dimRedResult}} objects. The names of the list
#'   will appear in the legend with the AUC_lnK value.
#' @param ndim the number of dimensions, if \code{NA} the original number of
#'   embedding dimensions is used, can be a vector giving the embedding
#'   dimensionality for each single list element of \code{x}.
#' @param weight the weight function used for K when calculating the AUC, one of
#'   \code{c("inv", "log", "log10")}
#' @family Quality scores for dimensionality reduction
#' @return A ggplot object, the design can be changed by appending
#'   \code{theme(...)}
#'
#' @examples
#' if(requireNamespace(c("RSpectra", "igraph", "RANN", "ggplot", "tidyr", "scales"), quietly = TRUE)) {
#' ## define which methods to apply
#' embed_methods <- c("Isomap", "PCA")
#' ## load test data set
#' data_set <- loadDataSet("3D S Curve", n = 200)
#' ## apply dimensionality reduction
#' data_emb <- lapply(embed_methods, function(x) embed(data_set, x))
#' names(data_emb) <- embed_methods
#' ## plot the R_NX curves:
#' plot_R_NX(data_emb) +
#'     ggplot2::theme(legend.title = ggplot2::element_blank(),
#'                    legend.position = c(0.5, 0.1),
#'                    legend.justification = c(0.5, 0.1))
#' }
#' @export
plot_R_NX <- function(x, ndim = NA, weight = "inv") {
    chckpkg("ggplot2")
    chckpkg("tidyr")
    chckpkg("scales")
    lapply(
        x,
        function(x)
        if (!inherits(x, "dimRedResult"))
            stop("x must be a list and ",
                 "all items must inherit from 'dimRedResult'")
    )

    rnx <- mapply(function(x, ndim) if(is.na(ndim)) R_NX(x) else R_NX(x, ndim),
                  x = x, ndim = ndim)

    weight <- match.arg(weight, c("inv", "ln", "log", "log10"))
    w_fun <- switch(
      weight,
      inv   = auc_ln_k_inv,
      log   = auc_log_k,
      ln    = auc_log_k,
      log10 = auc_log10_k,
      stop("wrong parameter for weight")
    )
    auc <- apply(rnx, 2, w_fun)

    df <- as.data.frame(rnx)
    df$K <- seq_len(nrow(df))

    qnxgrid <- expand.grid(K = df$K,
                           rnx = seq(0.1, 0.9, by = 0.1))
    ## TODO: FIND OUT WHY THIS AS IN THE PUBLICATION BUT IS WRONG!
    qnxgrid$qnx <- rnx2qnx(qnxgrid$rnx, K = qnxgrid$K, N = nrow(df)) #
    qnxgrid$rnx_group <- factor(qnxgrid$rnx)

    df <- tidyr::gather_(df,
                         key_col = "embedding",
                         value_col = "R_NX",
                         names(x))

    ggplot2::ggplot(df) +
        ggplot2::geom_line(ggplot2::aes_string(y = "R_NX", x = "K",
                                               color = "embedding")) +
        ## TODO: find out if this is wrong:
        ## ggplot2::geom_line(data = qnxgrid,
        ##                    mapping = ggplot2::aes_string(x = "K", y = "qnx",
        ##                                                  group = "rnx_group"),
        ##                    linetype = 2,
        ##                    size = 0.1) +
        ggplot2::geom_line(data = qnxgrid,
                           mapping = ggplot2::aes_string(x = "K", y = "rnx",
                                                         group = "rnx_group"),
                           linetype = 3,
                           size = 0.1) +
        ggplot2::scale_x_log10(
            labels = scales::trans_format("log10",
                                          scales::math_format()),
            expand = c(0, 0)
        ) +
        ggplot2::scale_y_continuous(expression(R[NX]),
                                    limits = c(0, 1),
                                    expand = c(0, 0)) +
        ggplot2::annotation_logticks(sides = "b") +
        ggplot2::scale_color_discrete(
                     breaks = names(x),
                     labels = paste(format(auc, digits = 3),
                                    names(x))) +
        ggplot2::labs(title = paste0(
                        "R_NX vs. K",
                        if (length(ndim) == 1 && !is.na(ndim))
                          paste0(", d = ", ndim)
                        else
                          ""
                      )) +
        ggplot2::theme_classic()
}
