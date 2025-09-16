# reprex.webr

An R package that provides a `reprex_webr()` function to generate WebR reproducible examples, inspired by the [reprex](https://reprex.tidyverse.org/) package.

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
```

## Features

- Generate shareable WebR URLs from R code
- Read code from clipboard (requires `clipr` package)
- Accepts code as an expression, character vector, file path, or clipboard
- Similar API to the `reprex` package
