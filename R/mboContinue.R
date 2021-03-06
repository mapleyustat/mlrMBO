#' @title Continues an mbo run from a save-file.
#'
#' @description
#' Useful if your optimization is likely to crash,
#' so you can continue from a save point and will not lose too much information and runtime.
#'
#' @param file [\code{character(1)}]\cr
#'   File path of saved MBO state.
#'   See \code{save.on.disk.at} argument of \code{\link{MBOControl}} object.
#' @return See \code{\link{mbo}}.
#' @export
mboContinue = function(file) {
  assertCharacter(file, len = 1L)
  if (!file.exists(file))
    stopf("Specified file '%s' does not exist.", file)

  # load the file and check if every required object exists
  f = try(load2(file, simplify = FALSE), silent = TRUE)
  if (is.error(f)) {
    # file is corrupted, look for backup file
    backup = getFileBackupName(file)
    if (file.exists(backup)) {
      showInfo("File '%s' corrupted, trying backup file '%s' instead", file, backup)
      f = load2(backup, simplify = FALSE)
      file.rename(backup, file)
    } else {
      stopf("Error reading file '%s': File is corrupted", file)
    }
  }
  if (any(c("fun", "learner", "par.set", "opt.path", "control", "show.info", "more.args", "models",
    "resample.results", "mbo.result", "random.seed") %nin% names(f)))
    stopf("Whatever the file contained you specified - it was not saved by mbo. Please specify a correct file.")

  # Restart mbo
  continue = f[c("opt.path", "models", "resample.results", "mbo.result")]

  # Restore the RNG-state
  .Random.seed = f$random.seed
  mboTemplate(f$fun, f$par.set, f$opt.path, f$learner, f$control, f$show.info, f$more.args, continue)
}
