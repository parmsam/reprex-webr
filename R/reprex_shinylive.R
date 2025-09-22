#' Create a shinylive.io Share URL from Shiny app code
#'
#' @description
#' Prepares Shiny app code for sharing and execution in a shinylive.io browser session by encoding it into a URL. Accepts code as an expression, character vector, file path, or from the clipboard, similar to reprex().
#'
#' @param x An expression. If not provided, will try `input`, then clipboard.
#' @param input Character. If length 1 and a file exists at that path, code is read from file. Otherwise, assumed to be code as character vector.
#' @param base_url The base shinylive.io URL for sharing (default: "https://shinylive.io/r/app/").
#' @param html_preview Logical. Whether to show rendered output in a viewer (RStudio or browser). Always FALSE in a noninteractive session.
#' @param copy_to_clipboard Logical. Whether to copy the URL to the clipboard (default: TRUE, only if interactive and clipr available).
#' @return A single string containing the shareable URL.
#' @export
#' @examples
#' \dontrun{
#' reprex_shinylive({
#'   library(shiny)
#'   ui <- fluidPage("Hello, world!")
#'   server <- function(input, output, session) {}
#'   shinyApp(ui, server)
#' })
#' reprex_shinylive(
#'   input = c("library(shiny)", "ui <- fluidPage('Hello, world!')", "server <- function(input, output, session) {}", "shinyApp(ui, server)"), 
#'   base_url = "https://shinylive.io/r/app/"
#' )
#' }
reprex_shinylive <- function(
  x = NULL,
  input = NULL,
  base_url = "https://shinylive.io/r/editor/",
  html_preview = TRUE,
  copy_to_clipboard = TRUE
) {
  if (!interactive()) html_preview <- FALSE

  x_missing <- missing(x)
  if (!x_missing) {
    code_lines <- deparse(substitute(x))
    if (length(code_lines) > 1 && grepl("^\\{", code_lines[1]) && grepl("\\}$", code_lines[length(code_lines)])) {
      code_lines <- code_lines[-c(1, length(code_lines))]
    }
    code_lines <- trimws(code_lines)
    code_lines <- code_lines[code_lines != ""]
  } else if (!is.null(input)) {
    if (length(input) == 1 && file.exists(input)) {
      code_lines <- readLines(input)
    } else {
      code_lines <- as.character(input)
    }
  } else if (interactive() && requireNamespace("clipr", quietly = TRUE) && clipr::clipr_available()) {
    code_lines <- clipr::read_clip()
  } else {
    stop("No code provided via x, input, or clipboard.")
  }

  if (!is.null(input) && identical(trimws(input), "")) {
    stop("No code to share: input is empty.")
  }
  code_string <- paste(code_lines, collapse = "\n")

  files <- list(
    name = jsonlite::unbox("app.R"),
    content = jsonlite::unbox(code_string)
  )
  files_json <- jsonlite::toJSON(list(files))
  files_lz <- lzstring::compressToEncodedURIComponent(as.character(files_json))
  share_url <- paste0(base_url, "#code=", files_lz)

  if (isTRUE(copy_to_clipboard) && interactive() && requireNamespace("clipr", quietly = TRUE) && clipr::clipr_available()) {
    clipr::write_clip(share_url)
    message("URL copied to clipboard.")
  }

  if (isTRUE(html_preview)) {
    utils::browseURL(share_url)
    invisible(share_url)
  } else {
    return(share_url)
  }
}
