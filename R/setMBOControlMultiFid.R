#FIXME: document breifly in mbo how multifid is enabled

#' @title Extends mbo control object with multiFid-algorithm specific options.
#'
#' @param control [\code{MBOControl}]\cr
#'   MBO control object.
#' @param param [\code{character(1)}]\cr
#'   The name of the parameter which increases the performance but also calculation costs.
#'   Must be a discrete parameter.
#' @param lvls [\code{numeric}]\cr
#'   The values of the param the learner should be trained with.
#' @param cor.grid.points [\code{integer(1)}]\cr
#'   Numbers of points used to calculate the correlation between the different levels of
#'   the \code{param}.
#' @param costs [\code{function}]\cr
#'   Vektorized (?) cost function with the params \code{cur} and \code{last}.
#' @param force.last.level.evals [\code{integer(1)}]
#'   How many evaluations should be done on the last value of fid.param?
#' @return [\code{\link{MBOControl}}].
#' @note See the other setMBOControl... functions and \code{makeMBOControl} for referenced arguments.
#' @seealso makeMBOControl
#' @export
setMBOControlMultiFid = function(control, param, lvls, costs = NULL, cor.grid.points = 10L,
  force.last.level.evals = 10L) {

  assertClass(control, "MBOControl")
  assertString(param)
  assertNumeric(lvls)
  if (!is.null(costs)){
    assertFunction(costs, args = c("cur", "last"), ordered = TRUE)
  } else {
    costs = function(cur, last) (last / cur)^2
  }
  cor.grid.point = asInt(cor.grid.points, lower = 2L)
  force.last.level.evals = asInt(force.last.level.evals, lower = 0L)

  # extend control object
  control$multifid = TRUE
  control$multifid.param = param
  control$multifid.lvls = lvls
  control$multifid.costs = costs
  control$multifid.cor.grid.points = cor.grid.points
  control$multifid.force.last.level.evals = force.last.level.evals

  return(control)
}
