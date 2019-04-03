# COREmisc


## Installation

  1. Install `devtools` if you haven't already.

``` r
install.packages("devtools")
```

  2. Install the package using `devtools`.
  
``` r
devtools::install_github("NPSCORELAB/COREmisc", upgrade="never")
```

## Using Functions Locally

``` r
table_out <- COREmisc::extract_html_table(file.choose())
edgelist <- COREmisc::extract_edgelist(table_out, "Author", "sent_to_val")
head(edgelist)
```

## Launching Apps Locally

``` r
COREmisc::launch_html_shiny_app()
```  
