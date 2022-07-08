#' Gets the directory of the rperform generated folder
dir_rperform <- function() {
  getOption("rperform.dir", "rperform")
}

#' Gets the path to the Rperform script
path_rperform_script <- function() {
  fs::path(dir_rperform(), "script.R")
}

#' Appends dir to Rbuildignore
#'
#' @param dir A String.
#'
#' @return A cli object
#'
#' @examples append_rbuildignore("Rperform")
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
        "Rperform not activated. Most likely, you want to run ",
        "{.code Rperform::activate()} and the below error should go away."
      )))
    }
    cli::cli_abort(c(paste0(
      "If you don't specify the argument {.arg branch(s)}, you must set the environment ",
      "variable {.envvar {var}} to tell {.pkg Rperform} ",
      "which branches you want to benchmark against each other."
    ),
    "i" = "See {.code ?Rperform::run_script}."
    ))
  } else {
    retrieved
  }
}

#' Creates a Pull Request Comment file
#'
#' @param test_results A Dataset.
#'
#' @param test_function A String.
#'
#' @param target_dir A String.
#'
create_pr_comment <- function(test_results, test_function, target_dir) {
  stopifnot(!is.null(test_results))
  typeof(test_results)
  suggested_pkgs <- c("ggplot2", "glue")
  suggests_available <- purrr::map_lgl(
    suggested_pkgs,
    requireNamespace,
    quietly = TRUE
  )

  if (!all(suggests_available)) {
    missing_pkgs <- suggested_pkgs[!suggests_available]
    n_pkgs <- length(missing_pkgs)
    pkgs_str <- paste0('"', missing_pkgs, '"', collapse = ",")
    cli::cli_abort(c(
      "Analysing the benchmarks requires {n_pkgs} additional package{?s}!",
      "i" = "To install use {.code install.packages(c({pkgs_str}))}"
    ))
  }

  path_info <- file.path(target_dir, paste0("comment", ".txt"))

  default_header <- paste(
    "The table below represents the test results generated",
    " after running `",
    test_function,
    "` function",
    " on this PR branch",
    "\n"
  )

  default_footer <- paste(
    "\n\nFurther explanation regarding interpretation and",
    " methodology can be found in the",
    "[documentation](https://github.com/analyticalmonk/Rperform#readme)."
  )

  ## write the header section
  write(get_comment_text("header", default_header),
    file = path_info
  )

  ## write the table section
  # m_table <- print(xtable::xtable(test_results),
  #   type = "html"
  # )
  # cat(m_table,
  #   file = path_info,
  #   append = TRUE
  # )

  ## write the footer section
  cat(get_comment_text("footer", default_footer),
    fill = TRUE,
    file = path_info,
    append = TRUE
  )

  readLines(path_info)
}


#' @return
#' Character vector of length one with the path to the pr comment.
#' @export
#' @seealso [pr_comment]
path_pr_comment <- function() {
  prepare_dir("./rperform/pr-comment")

  fs::path(dir_rperform(), "pr-comment/results.txt")
}

#' @return
#' Creates a new directory if it doesn't exist.
#' @param new_dir A String.
#'
#' @export
prepare_dir <- function(new_dir) {
  stopifnot(is.character(new_dir))

  if (!dir.exists(new_dir)) {
    dir.create(path = new_dir, recursive = TRUE)
  }
}

#' Modifying the PR Comment
#'
#' The files `rperform/header.R` and `rperform/footer.R` allow you to modify
#' the PR comment. You can use github markdown syntax to format the text.
#'
#' @name get_comment_text

get_comment_text <- function(part = c("footer", "header"), default,
                             env = parent.frame()) {
  part <- match.arg(part)
  file <- glue::glue("{part}.R")
  print(file)
  path <- fs::path(dir_rperform(), file)
  print(path)
  text <- default

  if (!fs::file_exists(path)) {
    cli::cli_alert_info("No comment {part} found. Using default.")
  } else {
    text <- eval(parse(path), envir = env)
    if (!is.character(text)) {
      cli::cli_warn(
        c("Parsed comment {part} is not a valid string. Using default.",
          "i" = "See {.code ?rperform::pr_comment} for more information."
        )
      )
      text <- default
    }
  }

  text
}