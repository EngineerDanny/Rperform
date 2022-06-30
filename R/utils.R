
dir_rperform <- function() {
  getOption("rperform.dir", "rperform")
}

path_rperform_script <- function() {
  fs::path(dir_rperform(), "script.R")
}

append_rbuildignore <- function(dir) {
  ignore <- ".Rbuildignore"
  dir_str <- glue::glue("^{dir}$")

  if (fs::file_exists(ignore)) {
    already_ignored <- any(readLines(ignore) == dir_str)

    if (!already_ignored) {
      cat(
        dir_str,
        sep = "\n", file = ignore, append = TRUE
      )
    }
    cli::cli_alert_success("Added {.path {dir}} to {.file {ignore}}.")
  } else {
    cli::cli_alert_warning(
      "Could not find {.file {ignore}} to add {.path {dir}}."
    )
  }
}


#' Get the branch from the environment variable or fail if not set
#'
#' This function is only exported because it is a default argument.
#' @param var The environment variable to retrieve.
#' @return
#' Returns a character vector of length one with the `branch` retrieved from the
#' environment variable `var`.
#' @export
branch_get_or_fail <- function(var) {
  retrieved <- Sys.getenv(var)
  if (!nzchar(retrieved)) {
    if (rlang::is_interactive()) {
      cli::cli_alert_info(c(paste0(
        "touchstone not activated. Most likely, you want to run ",
        "{.code touchstone::activate()} and the below error should go away."
      )))
    }
    cli::cli_abort(c(paste0(
      "If you don't specify the argument {.arg branch(s)}, you must set the environment ",
      "variable {.envvar {var}} to tell {.pkg touchstone} ",
      "which branches you want to benchmark against each other."
    ),
    "i" = "See {.code ?touchstone::run_script}."
    ))
  } else {
    retrieved
  }
}
