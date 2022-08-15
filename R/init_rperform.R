
#' Initializes Rperform by generating some files and adding them to the
#' rperform directory. It also makes Github Workflow Set-Up simpler.
#'
#' @param overwrite A Boolean.
#'
#' @return Returns a (temporarily) invisible copy of an object.
#'
#' @examples init_rperform()
init_rperform <- function(overwrite = FALSE) {
  rperform_dir <- dir_rperform()
  fs::dir_create(rperform_dir)

  workflows_dir <- fs::dir_create(fs::path(".github", "workflows"))

  has_written_script <- copy_if_not_exists(
    system.file("script.R", package = "Rperform"),
    path_rperform_script(),
    overwrite
  )

  copy_if_not_exists(
    system.file("header.R", package = "Rperform"),
    fs::path(rperform_dir, "header.R"),
    overwrite
  )

  copy_if_not_exists(
    system.file("footer.R", package = "Rperform"),
    fs::path(rperform_dir, "footer.R"),
    overwrite
  )

  copy_if_not_exists(
    system.file("config.json", package = "Rperform"),
    fs::path(rperform_dir, "config.json"),
    overwrite
  )

  copy_if_not_exists(
    system.file("gitignore", package = "Rperform"),
    fs::path(rperform_dir, ".gitignore"),
    overwrite
  )

  copy_if_not_exists(
    system.file("rperform-receive.yaml", package = "Rperform"),
    fs::path(workflows_dir, "rperform-receive.yaml"),
    overwrite
  )

  copy_if_not_exists(
    system.file("rperform-comment.yaml", package = "Rperform"),
    fs::path(workflows_dir, "rperform-comment.yaml"),
    overwrite
  )

  append_rbuildignore("Rperform")

  if (has_written_script) {
    cli::cli_ul(
      "Replace the sample code in `rperform/script.R` with the Rperform functions for the benchmarking."
    )
  }

  cli::cli_alert_info(
    "You can modify the PR comment with the header.R and footer.R."
  )

  cli::cli_ul(paste0(
    "Commit and push to GitHub to the default branch to activate the workflow, ",
    "then make a pull request to trigger your first benchmark run."
  ))
  invisible(NULL)
}

#' Copies a file if it doesn't exist.
#'
#' @param path Path to current file
#' @param new_path New path of the current file
#' @param overwrite A Boolean.
copy_if_not_exists <- function(path, new_path, overwrite = FALSE) {
  if (!fs::file_exists(new_path) || overwrite) {
    fs::file_copy(
      path,
      new_path,
      overwrite
    )
    cli::cli_alert_success("Populated file {.file {fs::path_file(new_path)}} in {.path {fs::path_dir(new_path)}/}.")
    TRUE
  } else {
    cli::cli_warn(paste0(
      "File {.file {fs::path_file(new_path)}} already exists",
      " at {.path {fs::path_dir(new_path)}/}, not copying."
    ))
    FALSE
  }
}

#' Runs the Rperform script.
#' 
#' @param path A String.
#' 
#' @examples
#' \dontrun{
#' run_script("inst/script.R")
#' } 
run_script <- function(path = "rperform/script.R") {

  source(path, max.deparse.length = Inf, local = TRUE)
}
