context("exampleRun")

test_that("renderExampleRunPlot produces list of ggplot2 objects", {
  library(ggplot2)
  library(soobench)

  n.iters = 1L

  doRun = function(obj.fn, par.set, predict.type, crit, learner = "regr.km", has.simple.signature = TRUE) {
    learner = makeLearner(learner, predict.type = predict.type)
    control = makeMBOControl(init.design.points = 10, iters = n.iters)
    control = setMBOControlInfill(control, crit = crit, opt = "focussearch", opt.focussearch.points = 10)
    if (has.simple.signature)
      obj.fn = makeMBOFunction(obj.fn)

    run = exampleRun(obj.fn, global.opt = 0L, par.set = par.set, learner = learner, control = control)
    return(renderExampleRunPlot(run, iter = 1L))
  }

  ### 1D NUMERIC
  obj.fn = function(x) sum(x*x)
  par.set = makeParamSet(
    makeNumericParam("x", lower = -2, upper = 2)
  )

  checkPlotList = function(plot.list) {
    expect_is(plot.list, "list")
    lapply(plot.list, function(pl) {
        # sometimes for example the 'se' plot is NA, if learner does not support standard error estimation
        if (!any(is.na(pl))) {
          expect_is(pl, "gg")
          expect_is(pl, "ggplot")
        }
    })
  }

  # without se
  plot.list = doRun(obj.fn, par.set, "response", "mean")
  checkPlotList(plot.list)

  # with se
  plot.list = doRun(obj.fn, par.set, "se", "ei")
  checkPlotList(plot.list)


  ### 2d MIXED
  obj.fn = function(x) {
    if (x$foo == "a")
      sum(x$x^2)
    else if (x$foo == "b")
      sum(x$x^2) + 10
    else
      sum(x$x^2) - 10
  }

  par.set = makeParamSet(
    makeDiscreteParam("foo", values = letters[1:3]),
    makeNumericVectorParam("x", len = 1, lower = -2, upper = 3)
  )

  plot.list = doRun(obj.fn, par.set, "se", "ei", "regr.randomForest", has.simple.signature = FALSE)
  checkPlotList(plot.list)

  ### 2D NUMERIC (MULTIPOINT)
  obj.fun = function(x) {
    sum(x^2)
  }

  par.set = makeNumericParamSet("x", len = 2L, lower = -5, upper = 5)

  ctrl = makeMBOControl(init.design.points = 5, iters = n.iters, propose.points = 3)
  ctrl = setMBOControlMultiPoint(ctrl,
    method = "multicrit",
    multicrit.objective = "ei.dist",
    multicrit.dist = "nearest.neighbor",
    multicrit.maxit = 200
  )

  lrn = makeLearner("regr.km", predict.type = "se", covtype = "matern3_2")

  run = exampleRun(makeMBOFunction(obj.fun), par.set = par.set, learner = lrn, control = ctrl, points.per.dim = 50)

  plot.list = renderExampleRunPlot(run, iter = 1L)
  checkPlotList(plot.list)
})
