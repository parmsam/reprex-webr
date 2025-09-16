test_that("reprex_webr returns a URL", {
  result <- reprex_webr("1 + 1")
  expect_type(result, "character")
  expect_true(grepl("^https://webr.sh", result))
})

test_that("reprex_webr handles multiple lines", {
  code <- c("x <- 1", "y <- 2", "x + y")
  result <- reprex_webr(code)
  expect_type(result, "character")
  expect_true(grepl("webr.sh", result))
})

test_that("reprex_webr validates venue", {
  expect_error(reprex_webr("1 + 1", venue = "invalid"), 
               "Currently only 'webr' venue is supported")
})

test_that("reprex_webr handles empty code", {
  expect_error(reprex_webr(""), "No code provided")
  expect_error(reprex_webr("   "), "No code provided")
})