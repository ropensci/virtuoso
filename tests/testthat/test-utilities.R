context("utilities")

test_that("we can detect valid and invalid file types", {
  files <- c("test.nq", "test2.nq.gz", "stuff.tar.gz")
  results <- assert_extensions(files)
  expect_false(results[[3]])
  expect_true(results[[2]])
})

test_that("we can guess extension", {
  expect_equal(guess_ext("test.nq"), "*.nq")
  expect_equal(guess_ext("test.nq.gz"), "*.nq.gz")
})

test_that("assert allowed dirs exits if server not connected ", {
  skip_if(!is.null(suppressMessages(vos_status())))

  expect_warning(
    assert_allowedDirs(),
    "ensure working directory is in allowedDirs"
  )
})
