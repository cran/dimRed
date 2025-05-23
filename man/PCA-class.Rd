% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/pca.R
\docType{class}
\name{PCA-class}
\alias{PCA-class}
\alias{PCA}
\title{Principal Component Analysis}
\description{
S4 Class implementing PCA.
}
\details{
PCA transforms the data in orthogonal components so that the first
axis accounts for the larges variance in the data, all the
following axes account for the highest variance under the
constraint that they are orthogonal to the preceding axes.  PCA is
sensitive to the scaling of the variables. PCA is by far the
fastest and simples method of dimensionality reduction and should
probably always be applied as a baseline if other methods are tested.
}
\section{Slots}{

\describe{
\item{\code{fun}}{A function that does the embedding and returns a
dimRedResult object.}

\item{\code{stdpars}}{The standard parameters for the function.}
}}

\section{General usage}{

Dimensionality reduction methods are S4 Classes that either be used
directly, in which case they have to be initialized and a full
list with parameters has to be handed to the \code{@fun()}
slot, or the method name be passed to the embed function and
parameters can be given to the \code{...}, in which case
missing parameters will be replaced by the ones in the
\code{@stdpars}.
}

\section{Parameters}{

PCA can take the following parameters:
\describe{
  \item{ndim}{The number of output dimensions.}
  \item{center}{logical, should the data be centered, defaults to \code{TRUE}.}
  \item{scale.}{logical, should the data be scaled, defaults to \code{FALSE}.}
}
}

\section{Implementation}{


Wraps around \code{\link{prcomp}}. Because PCA can be reduced to a
simple rotation, forward and backward projection functions are
supplied.
}

\examples{
dat <- loadDataSet("Iris")
emb <- embed(dat, "PCA")

plot(emb, type = "2vars")
if(requireNamespace("scatterplot3d", quietly = TRUE))
  plot(inverse(emb, getDimRedData(emb)), type = "3vars")

}
\references{
Pearson, K., 1901. On lines and planes of closest fit to systems of points in
space. Philosophical Magazine 2, 559-572.
}
\seealso{
Other dimensionality reduction methods: 
\code{\link{DRR-class}},
\code{\link{DiffusionMaps-class}},
\code{\link{DrL-class}},
\code{\link{FastICA-class}},
\code{\link{FruchtermanReingold-class}},
\code{\link{HLLE-class}},
\code{\link{Isomap-class}},
\code{\link{KamadaKawai-class}},
\code{\link{MDS-class}},
\code{\link{NNMF-class}},
\code{\link{PCA_L1-class}},
\code{\link{UMAP-class}},
\code{\link{dimRedMethod-class}},
\code{\link{dimRedMethodList}()},
\code{\link{kPCA-class}},
\code{\link{nMDS-class}},
\code{\link{tSNE-class}}
}
\concept{dimensionality reduction methods}
