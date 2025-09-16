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

# Generate WebR URL from code
reprex_webr("1 + 1")

# Generate WebR URL from clipboard
reprex_webr()

# Multiple lines of code
reprex_webr(c(
  "x <- 1:10",
  "mean(x)",
  "plot(x)"
))
```

## Features

- Generate shareable WebR URLs from R code
- Read code from clipboard (requires `clipr` package)
- Similar API to the `reprex` package
- Boilerplate implementation ready for extension

## Note

This is currently a boilerplate implementation. The WebR URL generation logic needs to be implemented to properly encode code for webr.sh.
