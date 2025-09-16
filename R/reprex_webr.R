#' Create a webR Share URL from R code
#'
#' @description
#' Prepares R code for sharing and execution in a webR browser session by 
#' encoding it into a URL. Accepts code as an expression, character vector, 
#' file path, or from the clipboard, similar to reprex().
#'
#' @param x An expression. If not provided, will try \code{input}, then clipboard.
#' @param input Character. If length 1 and a file exists at that path, code is read from file. 
#'   Otherwise, assumed to be code as character vector.
#' @param base_url The base webR URL for sharing (default: "https://webr.r-wasm.org/latest/").
#' @param html_preview Logical. Whether to show rendered output in a viewer (RStudio or browser). Always FALSE in a noninteractive session.
#' @param copy_to_clipboard Logical. Whether to copy the URL to the clipboard (default: TRUE, only if interactive and clipr available).
#' @return A single string containing the shareable URL.
#' @export
#' @examples
#' \dontrun{
#' clipr::write_clip('print("hello reprex!")')
#' reprex_webr()
#' reprex_webr(input = c("x <- 1:10", "plot(x, x^2)"))
#' reprex_webr({x <- 1:10; plot(x, x^2)})
#' }
#'
reprex_webr <- function(
  x = NULL,
  input = NULL,
  base_url = "https://webr.r-wasm.org/latest/",
  html_preview = TRUE,
  copy_to_clipboard = TRUE
) {
  if (!interactive()) html_preview <- FALSE

  # Always use deparse(substitute(x)) if x is provided
  x_missing <- missing(x)
  if (!x_missing) {
    code_lines <- deparse(substitute(x))
    # Remove wrapping braces if present
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
  } else if (interactive() && clipr::clipr_available()) {
    code_lines <- clipr::read_clip()
  } else {
    stop("No code provided via x, input, or clipboard.")
  }

  if (!is.null(input) && identical(trimws(input), "")) {
    stop("No code to share: input is empty.")
  }
  code_string <- paste(code_lines, collapse = "\n")

  item <- list(
    name = "main.R",
    path = "/home/web_user/main.R",
    text = code_string
  )

  msgpack_data <- RcppMsgPack::msgpack_pack(list(item))
  zlib_data <- memCompress(msgpack_data, "gzip")
  b64_data <- base64enc::base64encode(zlib_data)
  url_code <- utils::URLencode(b64_data, reserved = TRUE)
  share_url <- paste0(base_url, "#code=", url_code)

  if (isTRUE(copy_to_clipboard) && interactive() && clipr::clipr_available()) {
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
