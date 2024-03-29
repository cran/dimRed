% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/plot.R
\name{plot_R_NX}
\alias{plot_R_NX}
\title{plot_R_NX}
\usage{
plot_R_NX(x, ndim = NA, weight = "inv")
}
\arguments{
\item{x}{a list of \code{\link{dimRedResult}} objects. The names of the list
will appear in the legend with the AUC_lnK value.}

\item{ndim}{the number of dimensions, if \code{NA} the original number of
embedding dimensions is used, can be a vector giving the embedding
dimensionality for each single list element of \code{x}.}

\item{weight}{the weight function used for K when calculating the AUC, one of
\code{c("inv", "log", "log10")}}
}
\value{
A ggplot object, the design can be changed by appending
  \code{theme(...)}
}
\description{
Plot the R_NX curve for different embeddings. Takes a list of
\code{\link{dimRedResult}} objects as input.
Also the Area under the curve values are computed for a weighted K
(see \link{AUC_lnK_R_NX} for details) and appear in the legend.
}
\examples{
if(requireNamespace(c("RSpectra", "igraph", "RANN", "ggplot", "tidyr", "scales"), quietly = TRUE)) {
## define which methods to apply
embed_methods <- c("Isomap", "PCA")
## load test data set
data_set <- loadDataSet("3D S Curve", n = 200)
## apply dimensionality reduction
data_emb <- lapply(embed_methods, function(x) embed(data_set, x))
names(data_emb) <- embed_methods
## plot the R_NX curves:
plot_R_NX(data_emb) +
    ggplot2::theme(legend.title = ggplot2::element_blank(),
                   legend.position = c(0.5, 0.1),
                   legend.justification = c(0.5, 0.1))
}
}
\seealso{
Other Quality scores for dimensionality reduction: 
\code{\link{AUC_lnK_R_NX,dimRedResult-method}},
\code{\link{LCMC,dimRedResult-method}},
\code{\link{Q_NX,dimRedResult-method}},
\code{\link{Q_global,dimRedResult-method}},
\code{\link{Q_local,dimRedResult-method}},
\code{\link{R_NX,dimRedResult-method}},
\code{\link{cophenetic_correlation,dimRedResult-method}},
\code{\link{distance_correlation,dimRedResult-method}},
\code{\link{mean_R_NX,dimRedResult-method}},
\code{\link{quality,dimRedResult-method}},
\code{\link{reconstruction_error,dimRedResult-method}},
\code{\link{reconstruction_rmse,dimRedResult-method}},
\code{\link{total_correlation,dimRedResult-method}}
}
\concept{Quality scores for dimensionality reduction}
