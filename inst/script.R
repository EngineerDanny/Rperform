# The script should be written here to benchmark the package on Github.
# NOTE: save_data argument must be set to TRUE for plot_metrics functions.

## TEST 1
# Rperform::plot_metrics(
#     test_path = "inst/tests/test-join.r",
#     metric = "time", num_commits = 5, save_data = TRUE,
#     save_plots = TRUE,
# )


## TEST 2
# Rperform::plot_metrics(
#     test_path = "inst/tests/test-join.r",
#     metric = "memory", num_commits = 5, save_data = TRUE,
#     save_plots = TRUE,
# )

## TEST 3
# Rperform::time_compare(
#    test_path = "inst/tests/test-dup.r",
#    num_commits = 2, save_data = TRUE,
# )

## TEST 4
# Rperform::mem_compare(
#    test_path = "inst/tests/test-dup.r",
#    num_commits = 2, save_data = TRUE,
# )
