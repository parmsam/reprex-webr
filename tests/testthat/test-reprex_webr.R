test_that("reprex_webr returns a URL", {
  result <- reprex_webr("1 + 1", html_preview = FALSE)
  expect_type(result, "character")
  expect_true(grepl("^https://webr.r-wasm.org/latest", result))
})

test_that("reprex_webr handles multiple lines", {
  code <- c("x <- 1", "y <- 2", "x + y")
  result <- reprex_webr(code, html_preview = FALSE)
  expect_type(result, "character")
  expect_true(grepl("webr.r-wasm.org", result))
})

test_that("reprex_webr handles empty code", {
  expect_error(reprex_webr(input = "", html_preview = FALSE))
  expect_error(reprex_webr(input = "   ", html_preview = FALSE))
})

test_that("reprex handles R expression input", {
  result <- reprex_webr({a <- 5; b <- 10; a * b}, html_preview = FALSE)
  expect_type(result, "character")
  expect_true(grepl("webr.r-wasm.org", result))
})

test_that("reprex_webr handles file input", {
  temp_file <- tempfile(fileext = ".R")
  writeLines(c("a <- 10", "b <- 20", "a + b"), temp_file)
  result <- reprex_webr(input = temp_file, html_preview = FALSE)
  expect_type(result, "character")
  expect_true(grepl("webr.r-wasm.org", result))
  unlink(temp_file)
})
