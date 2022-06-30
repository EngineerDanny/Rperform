

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
      "Replace the mtcars sample code in `Rperform/script.R` with code from your package you want to benchmark."
    )
  }

  cli::cli_alert_info(
    "You can modify the PR comment, see {.code ?Rperform::pr_comment}."
  )

  cli::cli_ul(paste0(
    "Commit and push to GitHub to the default branch to activate the workflow, ",
    "then make a pull request to trigger your first benchmark run."
  ))
  invisible(NULL)
}

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


run_script <- function(path = "inst/script.R") {
  # force(branch)
  # rlang::with_interactive(
  #   activate(branch, branch_get_or_fail("GITHUB_BASE_REF")), TRUE
  # )

  # temp_file <- fs::file_temp()
  # fs::file_copy(path, temp_file)

  # cli::cli_alert_success(paste0(
  #   "Copied Rperform script to tempdir to prevent branch checkouts to effect",
  #   " the script."
  # ))

  source(path, max.deparse.length = Inf, local = TRUE)
}
