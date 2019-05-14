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
html_in <- htmltools::HTML(file.choose())
table_out <- COREmisc::extract_html_table(html_in)
edgelist <- COREmisc::extract_edgelist(table_out, "Author", "sent_to_val")
head(edgelist)
```

or

``` r
df <- read.csv(file.choose())
geocoded_df <- COREmisc::find_ip(df)
```

## Launching Apps Locally

``` r
COREmisc::launch_shiny_app()
```  
