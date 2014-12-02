library(devtools)
load_all(".")
source("todo-files/test_functions.R")
options(warn = 2)
e.lvls = c(0.3, 1)

ctrl = makeMBOControl(
  init.design.points = 20L, 
  init.design.fun = maximinLHS,
  iters = 6L,
  on.learner.error = "stop",
  show.learner.output = FALSE
)

ctrl = setMBOControlInfill(
  crit = "multiFid",
  control = ctrl, 
  opt = "focussearch", 
  opt.restarts = 1L, 
  opt.focussearch.maxit = 1L, 
  opt.focussearch.points = 100L,
  filter.proposed.points = TRUE,
  filter.proposed.points.tol = 0.001
)

ctrl = setMBOControlMultiFid(
  control = ctrl, 
  param = "dw.perc", 
  lvls = e.lvls,
  cor.grid.points = 20L,
  costs = function(cur, last) (last / cur)^1.2,
)

par.set = makeParamSet(
  makeNumericParam(id = "x", lower = 0, upper = 10))

lrn = makeLearner("regr.km", nugget.estim = TRUE, jitter = TRUE)

obj = makeMBOMultifidFunction(addDistortion(addDistortion(sasena, g=yshift), noiseGaussian), lvls = ctrl$multifid.lvls)
res = mbo(fun = obj, par.set = par.set, control = ctrl, learner = lrn, show.info = TRUE)

for(i in seq_along(res$plot.data)) {
  print(genGgplot(plotdata=res$plot.data[[i]]))
  cat ("Press [enter] to continue")
  line <- readline()
}