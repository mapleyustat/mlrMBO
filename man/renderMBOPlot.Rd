% Generated by roxygen2 (4.1.0): do not edit by hand
% Please edit documentation in R/renderMBOPlot.R
\name{renderMBOPlot}
\alias{renderMBOPlot}
\title{Renders plots for MBO result objects, every dimension is supported. Renders
a plot for X and Y Space respectively, additional diagnostic plots are available.}
\usage{
renderMBOPlot(result, iter, crit.plot = TRUE, hv.plot = NA,
  extra.measures = NULL, ref.point = NULL, lim.x = list(),
  lim.y = list())
}
\arguments{
\item{result}{[\code{MBOResult}]\cr
\code{MBOSingleObjResult} or \code{MBOMultiObjResult} object.}

\item{iter}{[\code{integer(1)}]\cr
Selected iteration of \code{object} to render plots for.}

\item{crit.plot}{[\code{logical(1)}]\cr
Should the infill criterion versus the iteration be plotted? For multi objective
and method = MSPOT multiple infill criterion values per iterion do exist,
so a multi-dimensional plot is used. Default is TRUE}

\item{hv.plot}{[\code{logical(1)}]\cr
Should the hypervolume development be plotted? Default is FALSE for single
objective und TRUE for multi objective.}

\item{extra.measures}{[\code{character}]\cr
 Additional measures to be plotted versus the iteration. Must be the name
 of a coloumn available in the optimization path. Notice that at most 4 plost
 can be renderd at the same time. Since X and Y Space plots will allways be
 rendered, at most 2 addition plots are possible. You must deactivate crit.plot
 or hv.plot, if you want to add additional plots via extra.measure.}

\item{ref.point}{[\code{numeric}]\cr
  Reference point used for the hypervolume development plot. Length of vector
  must equal the dimensionality of the optimization problem. Default is
  \code{NULL}, in this case the maximum / minimum values in the optimization
  path, that are alive in iteration iter, are used and increased / decreased
  by 0.1 (depending on minimization / maximization of the objective).}

\item{lim.x}{[\code{list}],}

\item{lim.y}{[\code{list}]\cr
Axis limits for the plots. Must be a named list, so you can specify the
axis limits for every plot. Every element of the list must be a numeric
vector of length 2. Available names for elements are:
XSpace - limits for the X-Space plot
YSpaCe - limits for the Y-Space plot
CritPlot - limits for the plot infill criterion plot
HVPlot - limits for the Hypervolume Plit
Extra1Plot - Limits for the Plot given by the first element of extra.measure
Extra2Plot - Limits for the Plot given by the second element of extra.measure
Default is an empty list - in this case limits are automatically set.}
}
\description{
Renders plots for MBO result objects, every dimension is supported. Renders
a plot for X and Y Space respectively, additional diagnostic plots are available.
}

