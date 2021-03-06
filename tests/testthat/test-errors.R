testthat::context("Error Handling")

Sys.setenv(piggyback_cache_duration="1e-6")
tmp <- tempdir()

testthat::test_that(
  "Attempt upload without authentication", {
    readr::write_tsv(datasets::iris, "iris3.tsv.gz")
    testthat::expect_error(
      out <- pb_upload(
        repo = "cboettig/piggyback-tests",
        file = "iris3.tsv.gz",
        tag = "v0.0.1",
        overwrite = TRUE,
        .token = "not_valid_token",
        show_progress = FALSE
      ),
      "GITHUB_TOKEN"
    )
    unlink("iris.tsv.gz")
  }
)




testthat::test_that(
  "Attempt overwrite on upload when overwrite is FALSE", {
    testthat::skip_on_cran()

    data <- readr::write_tsv(datasets::iris, "iris2.tsv.gz")
    testthat::expect_warning(
      out <- pb_upload(
        repo = "cboettig/piggyback-tests",
        file = "iris2.tsv.gz",
        tag = "v0.0.1",
        overwrite = FALSE,
        show_progress = FALSE
      ),
      "Skipping upload of iris2.tsv.gz as file exists"
    )
    unlink("iris2.tsv.gz")
  }
)



testthat::test_that(
  "Attempt upload non-existent file", {
    testthat::skip_on_cran()

    testthat::expect_warning(
      out <- pb_upload(
        repo = "cboettig/piggyback-tests",
        file = "not-a-file",
        tag = "v0.0.1",
        use_timestamps = FALSE,
        show_progress = FALSE
      ),
      "not-a-file does not exist"
    )

  }
)


testthat::test_that(
  "Attempt download non-existent file", {
    testthat::skip_on_cran()

    testthat::expect_warning(
      out <- pb_download(
        repo = "cboettig/piggyback-tests",
        file = "not-a-file",
        tag = "v0.0.1",
        dest = tmp,
        show_progress = FALSE
      ),
      "not found"
    )

  }
)

testthat::test_that(
  "Attempt upload to non-existent tag", {
    testthat::skip_on_cran()

    ## Note: in interactive use this will prompt instead
    skip_if(interactive())

    data <- readr::write_tsv(datasets::iris, "iris.tsv.gz")

    testthat::expect_error(
      out <- pb_upload(
        repo = "cboettig/piggyback-tests",
        file = "iris.tsv.gz",
        tag = "not-a-tag",
        overwrite = TRUE,
        show_progress = FALSE
      ),
      "No release with tag not-a-tag exists"
    )


    unlink("iris.tsv.gz")
  }
)




testthat::test_that(
  "Attempt overwrite on download when overwrite is FALSE", {
    testthat::skip_on_cran()

    data <- readr::write_tsv(datasets::iris, file.path(tmp, "iris2.tsv.gz"))
    testthat::expect_warning(
      out <- pb_download(
        repo = "cboettig/piggyback-tests",
        file = "iris2.tsv.gz",
        dest = tmp,
        tag = "v0.0.1",
        overwrite = FALSE,
        use_timestamps = FALSE,
        show_progress = FALSE
      ),
      "exists"
    )
    unlink("iris2.tsv.gz")
  }
)

testthat::test_that(
  "Attempt to delete non-existent file", {
    testthat::expect_message(
      pb_delete(
        repo = "cboettig/piggyback-tests",
        file = "mtcars2.tsv.gz",
        tag = "v0.0.1"
      ),
      "not found on GitHub"
    )
  }
)


testthat::test_that(
  "message when tag already exists", {

    testthat::expect_error(
      pb_new_release(
        repo = "cboettig/piggyback-tests",
        tag = "v0.0.1"
      ),
      "already exists"
    )

  }
)


test_that("download url error", {
  testthat::expect_error(
  x <- pb_download_url("not-a-file",
    repo = "cboettig/piggyback-tests",
    tag = "v0.0.1",
    .token = piggyback:::get_token()
  ), "not-a-file")
})
