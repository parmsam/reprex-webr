# reprex.webr

An R package that provides `reprex_webr()`/`reprex_shinylive()` functions to generate WebR or SHinylive reproducible examples, inspired by the [reprex](https://reprex.tidyverse.org/) package.

## Installation

You can install the development version of reprex.webr from GitHub:

```r
# install.packages("devtools")
devtools::install_github("parmsam/reprex_webr")
```

## Usage

```r
library(reprex.webr)
library(clipr)

# Generate WebR URL from clipboard
write_clip("1 + 5")
reprex_webr()

# Generate WebR URL from code
reprex_webr(input = "1 + 1")

# Multiple lines of code
reprex_webr(input = c(
  "x <- 1:10",
  "mean(x)",
  "plot(x)"
))

# Pass an expression directly
reprex_webr({
  x <- 1:10
  mean(x)
  plot(x)
})

# Generate shinylive.io URL from Shiny app code (NEW)
reprex_shinylive({
  library(shiny)
  ui <- fluidPage("Hello, world!")
  server <- function(input, output, session) {}
  shinyApp(ui, server)
})

# Or from a character vector
reprex_shinylive(input = c(
  "library(shiny)",
  "ui <- fluidPage('Hello, world!')",
  "server <- function(input, output, session) {}",
  "shinyApp(ui, server)"
))
```

## Features

- Generate shareable WebR URLs from R code
- Generate shareable shinylive.io URLs from Shiny app code (NEW)
- Read code from clipboard (requires `clipr` package)
- Accepts code as an expression, character vector, file path, or clipboard
- Similar API to the `reprex` package
