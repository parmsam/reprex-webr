test_that("reprex_shinylive returns a URL for expression", {
  result <- reprex_shinylive({
    library(shiny)
    ui <- fluidPage("Hello, world!")
    server <- function(input, output, session) {}
    shinyApp(ui, server)
  }, html_preview = FALSE, copy_to_clipboard = FALSE)
  expect_type(result, "character")
  expect_true(grepl("^https://shinylive.io/r/app/", result))
})

test_that("reprex_shinylive returns a URL for character input", {
  code <- c(
    "library(shiny)",
    "ui <- fluidPage('Hello, world!')",
    "server <- function(input, output, session) {}",
    "shinyApp(ui, server)"
  )
  result <- reprex_shinylive(input = code, html_preview = FALSE, copy_to_clipboard = FALSE)
  expect_type(result, "character")
  expect_true(grepl("^https://shinylive.io/r/app/", result))
})

test_that("reprex_shinylive handles empty input", {
  expect_error(reprex_shinylive(input = "", html_preview = FALSE, copy_to_clipboard = FALSE))
  expect_error(reprex_shinylive(input = "   ", html_preview = FALSE, copy_to_clipboard = FALSE))
})
