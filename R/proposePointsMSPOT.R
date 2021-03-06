proposePointsMSPOT = function(models, par.set, control, opt.path, iter, ...) {
  n = control$propose.points
  ch = checkFailedModels(models, par.set, n, control = control)
  if (!ch$ok)
    return(ch$prop)

  design = convertOptPathToDf(par.set, opt.path, control)
  infill.crit.fun = getInfillCritFunction(control$infill.crit)
  infill.opt.fun = getInfillOptFunction(control$infill.opt)

  # store time to propose single point
  st = system.time({
    prop.points = infill.opt.fun(infill.crit.fun, models, control, par.set, opt.path, design, iter, ...)
  })

  ppoints = prop.points$prop.points
  crit.vals = evalCritFunForMultiCritModels(infill.crit.fun, ppoints, models, control,
    par.set, design, iter)
  crit.vals = cbind(crit.vals, prop.points$prop.hv.contrs)

  return(list(prop.points = ppoints, propose.time = st[3L], crit.vals = crit.vals, errors.model = NA_character_))
}


