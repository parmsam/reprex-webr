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
#' @return A single string containing the shareable URL.
#' @export
#' @examples
#' clipr::write_clip('print("hello reprex!")')
#' reprex_webr()
#' reprex_webr(input = c("x <- 1:10", "plot(x, x^2)"))
#' reprex_webr({x <- 1:10; plot(x, x^2)})
#'
reprex_webr <- function(
    x = NULL,
    input = NULL,
    base_url = "https://webr.r-wasm.org/latest/",
    html_preview = TRUE
) {
  # In non-interactive sessions, always FALSE
  if (!interactive()) html_preview <- FALSE
  
  # Helper: get code as character
  get_code <- function(x, input) {
    # 1. If x is present
    if (!is.null(x)) {
      x_expr <- substitute(x)
      # If x is a call or expression, deparse to lines
      if (is.call(x_expr) || is.expression(x_expr)) {
        code <- deparse(x_expr)
        # Remove wrapping braces if present
        if (length(code) > 1 && grepl("^\\{", code[1]) && grepl("\\}$", code[length(code)])) {
          code <- code[-c(1, length(code))]
        }
        code <- trimws(code)
        code <- code[code != ""]
        return(code)
      }
      # If x is a character vector, use as code
      if (is.character(x)) {
        return(as.character(x))
      }
    }
    # 2. If input is a file path
    if (!is.null(input)) {
      if (length(input) == 1 && file.exists(input)) {
        return(readLines(input))
      }
      # Otherwise, treat as code vector
      return(as.character(input))
    }
    # 3. Fallback: clipboard (only if interactive)
    if (interactive()) {
      if (clipr::clipr_available()) {
        return(clipr::read_clip())
      }
    }
    stop("No code provided via x, input, or clipboard.")
  }
  
  if (identical(trimws(input), "")) {
    stop("No code to share: input is empty.")
  }
  code_lines <- get_code(x, input)
  # Collapse code into single string
  code_string <- paste(code_lines, collapse = "\n")
  
  # Build the item list as per webR ShareItem structure
  item <- list(
    name = "main.R",
    path = "/home/web_user/main.R",
    text = code_string
  )
  
  # Encode as webR expects: MessagePack -> zlib -> base64 -> URL encode
  msgpack_data <- RcppMsgPack::msgpack_pack(list(item))
  zlib_data <- memCompress(msgpack_data, "gzip")
  b64_data <- base64enc::base64encode(zlib_data)
  url_code <- utils::URLencode(b64_data, reserved = TRUE)
  share_url <- paste0(base_url, "#code=", url_code)

  # Preview in viewer or browser if requested
  if (isTRUE(html_preview)) {
    utils::browseURL(share_url)
    invisible(share_url)
  } else {
    return(share_url)
  }
}
