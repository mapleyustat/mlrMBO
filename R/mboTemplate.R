#  Optimizes a multicrit optimization problem with the SMS EGO algo

mboTemplate = function(fun, par.set, design = NULL, learner, control, show.info = TRUE,
  more.args = list(), continue = NULL) {

  # save currently set options
  oldopts = list(
    ole = getOption("mlr.on.learner.error"),
    slo = getOption("mlr.show.learner.output")
  )

  # termination
  start.time = Sys.time()
  iters = control$iters
  time.budget = control$time.budget

  # shortcut names
  ninit = if (is.null(design)) control$init.design.points else nrow(design)
  crit = control$infill.crit
  y.name = control$y.name
  crit = control$infill.crit
  islcb = (control$propose.points > 1L && control$multipoint.method == "lcb")
  ninit = if (is.null(design)) control$init.design.points else nrow(design)
  fevals = control$final.evals

  algo.init = mboAlgoInit(par.set, opt.path, control)

  # for normal start, we setup initial design, otherwise take stuff from continue object from disk
  if (is.null(continue)) {
    opt.path = makeMBOOptPath(par.set, control)
    extras = getExtras(ninit, NULL, control)
    generateMBODesign(design, fun, par.set, opt.path, control, show.info, oldopts, more.args, extras)
    stored.models = namedList(control$store.model.at)
    resample.results = namedList(control$resample.at)
  } else {
    if (!is.null(continue$mbo.result)) {
      warningf("mboContinue: No need to continue, we were already finished. Simply returning stored result.")
      return(continue$mbo.result)
    }
    opt.path = continue$opt.path
    stored.models = continue$stored.models
    resample.results = continue$resample.results
  }

  tasks = makeTasks(par.set, opt.path, algo.init, control = control)
  current.models = lapply(tasks, train, learner = learner)

  # if we are restarting from a save file, we possibly start in a higher iteration
  loop = max(getOptPathDOB(opt.path)) + 1L

  # small helper for learner resampling
  # if we have multiple tasks, return a list, otherwise singleton result
  doResample = function(tasks) {
    if (length(tasks) == 1L)
      resample(learner, tasks[[1L]], control$resample.desc, measures = control$resample.measures)
    else
      lapply(tasks, resample, learner = learner, resampling = control$resample.desc,
        measures = control$resample.measures)
  }

  # save some stuff for iter 0, not necessary if we continue
  if (is.null(continue)) {
    if (0L %in% control$store.model.at)
      stored.models[["0"]] = if (length(current.models) == 1L) current.models[[1L]] else current.models
    if (0L %in% control$resample.model.at)
      resample.results[["0"]] = doResample(tasks)
    saveStateOnDisk(0L, fun, learner, par.set, opt.path, control, show.info, more.args,
      stored.models, resample.results, NULL)
  }

  repeat {
    # propose new points and evaluate target function
    prop = proposePoints(tasks, current.models, par.set, control, opt.path, iter = loop)
    crit.vals = prop$crit.vals
    extras = getExtras(nrow(prop$prop.points), prop, control)
    evalProposedPoints(loop, prop$prop.points, par.set, opt.path, control,
      fun, learner, show.info, oldopts, more.args, extras)

    # train models
    tasks = makeTasks(par.set, opt.path, algo.init, control)
    current.models = lapply(tasks, train, learner = learner)

    # store models + resample + store on disk
    if (loop %in% control$store.model.at)
      stored.models[[as.character(loop)]] = if (length(current.models) == 1L) current.models[[1L]] else current.models
    if (loop %in% control$resample.at)
      resample.results[[as.character(loop)]] = doResample(tasks)
    saveStateOnDisk(loop, fun, learner, par.set, opt.path, control, show.info, more.args, stored.models,
      resample.results, NULL)

    # increase loop counter and check if done
    loop = loop + 1L
    terminate = shouldTerminate(iters, loop, time.budget, start.time)
    if (terminate >= 0)
      break
  }
  # restore mlr configuration
  configureMlr(on.learner.error = oldopts[["ole"]], show.learner.output = oldopts[["slo"]])

  if (control$number.of.targets == 1L) {
    final.index = chooseFinalPoint(fun, par.set, current.models[[1L]], opt.path, y.name, control)
    if (fevals > 0L) {
      # do some final evaluations and compute mean of target fun values
      showInfo(show.info, "Performing %i final evals", fevals)
      best = getOptPathEl(opt.path, final.index)
      xs = replicate(fevals, best$x, simplify = FALSE)
      extras = getExtras(fevals, NULL, control)
      ys = evalTargetFun(fun, par.set, loop, xs, opt.path, control, show.info, oldopts, more.args, extras)
      best$y = mean(ys)
    }
    res = makeMBOSingleObjResult(final.index, opt.path, resample.results, terminate, stored.models)
  } else {
    res = makeMBOMultiCritResult(opt.path, terminate, stored.models)
  }
  # make sure to save final res on disk
  saveStateOnDisk(loop, fun, learner, par.set, opt.path, control, show.info, more.args, stored.models,
    resample.results, res)

  return(res)
}

