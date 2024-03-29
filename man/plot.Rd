% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/plot.R
\name{plot}
\alias{plot}
\alias{plot.dimRed}
\alias{plot,dimRedData,ANY-method}
\alias{plot.dimRedData}
\alias{plot,dimRedResult,ANY-method}
\alias{plot.dimRedResult}
\title{Plotting of dimRed* objects}
\usage{
plot(x, y, ...)

\S4method{plot}{dimRedData,ANY}(
  x,
  type = "pairs",
  vars = seq_len(ncol(x@data)),
  col = seq_len(min(3, ncol(x@meta))),
  ...
)

\S4method{plot}{dimRedResult,ANY}(
  x,
  type = "pairs",
  vars = seq_len(ncol(x@data@data)),
  col = seq_len(min(3, ncol(x@data@meta))),
  ...
)
}
\arguments{
\item{x}{dimRedResult/dimRedData class, e.g. output of
embedded/loadDataSet}

\item{y}{Ignored}

\item{...}{handed over to the underlying plotting function.}

\item{type}{plot type, one of \code{c("pairs", "parpl", "2vars",
"3vars", "3varsrgl")}}

\item{vars}{the axes of the embedding to use for plotting}

\item{col}{the columns of the meta slot to use for coloring, can be
referenced as the column names or number of x@data}
}
\description{
Plots a object of class dimRedResult and dimRedData. For the
documentation of the plotting function in base see here:
\code{\link{plot.default}}.
}
\details{
Plotting functions for the classes usind in \code{dimRed}. they are
intended to give a quick overview over the results, so they are
somewhat inflexible, e.g. it is hard to modify color scales or
plotting parameters.

If you require more control over plotting, it is better to convert
the object to a \code{data.frame} first and use the standard
functions for plotting.
}
\section{Methods (by class)}{
\itemize{
\item \code{x = dimRedData,y = ANY}: Ploting of dimRedData objects

\item \code{x = dimRedResult,y = ANY}: Ploting of dimRedResult objects.
}}

\examples{
scurve = loadDataSet("3D S Curve")
if(requireNamespace("graphics", quietly = TRUE))
  plot(scurve, type = "pairs", main = "pairs plot of S curve")
if(requireNamespace("MASS", quietly = TRUE))
  plot(scurve, type = "parpl")
if(requireNamespace("graphics", quietly = TRUE))
  plot(scurve, type = "2vars", vars = c("y", "z"))
if(requireNamespace("scatterplot3d", quietly = TRUE))
  plot(scurve, type = "3vars")
if(requireNamespace("rgl", quietly = TRUE))
  plot(scurve, type = "3varsrgl")

}
