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
#' @param dir The directory append Rbuildignore to
#'
#' @examples
#' \dontrun{
#' append_rbuildignore("Rperform")
#' }
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
#' @param folder_name A String.
#'
create_pr_comment <- function(test_results, test_function,
                              target_dir, folder_name) {
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

  # use git2r to get the current branch name
  repo <- git2r::repository("./")
  remote_url <- git2r::remote_url(repo)
  repo_name <- basename(remote_url)
  repo_owner <- sub(".*[github.com]/(.+)/.*", "\\1", remote_url)

  image_url <- paste0(
    "![image](https://raw.githubusercontent.com/",
    repo_owner, "/", repo_name,
    "/rperform-branch/rperform-results/", folder_name, "/test_image.png)"
  )

  csv_url <- paste0(
    "[here](https://raw.githubusercontent.com/",
    repo_owner, "/", repo_name,
    "/rperform-branch/rperform-results/", folder_name, "/test_data.csv)"
  )

  path_info <- file.path(target_dir, paste0("comment", ".txt"))

  default_header <- paste(
    "The image below represents the test results generated",
    " after running `",
    test_function,
    "` function",
    " on this PR branch. ",
    "Check out the test results data set in csv ",
    csv_url,
    "\n",
    "<br/>",
    image_url
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

  ## write the footer section
  cat(get_comment_text("footer", default_footer),
    fill = TRUE,
    file = path_info,
    append = TRUE
  )

  readLines(path_info)
}

#' Creates a new directory if it doesn't exist.
#' @param new_dir The directory to create.
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
#' @param part The section of the comment to modify.
#' @param default The default text to use if the file does not exist.
#' @param env The environment variable to use.
#'
#' @export
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
    text <- base::eval(base::parse(path), envir = env)
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
