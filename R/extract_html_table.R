#' @title Extract HTML Table
#'
#' @description `extract_table` returns a `data.frame` with the values in the HTML.
#'
#' @author Christopher Callaghan, \email{cjcallag@@nps.edu}
#' @author Brendan Knapp, \email{brendan.knapp@@nps.edu}
#'
#' @param .html, An `HTML` file like the example
#'
#' @examples
#' library(COREmisc)
#'
#' le_html <- htmltools::HTML()
#' out_table <- extract_html_table(le_html)
#' head(out(table))
#'
#' @seealso Uses funcitons from `magrittr` [magrittr::`%>%`],
#' `dplyr` [dplyr::bind_rows][dplyr::distinct][dplyr::group_split][dplyr::if_else][dplyr::mutate][dplyr::mutate_if][dplyr::select][dplyr::starts_with],
#' `purr` [purrr::map][purrr::map_dfr],
#' `rlang` [rlang::`!!!`][rlang::set_names][rlang::syms],
#' `rvest` [rvest::html_nodes][rvest::html_table],
#' `tibble` [tibble::as_tibble],
#' `tidyr` [tidyr::fill][tidyr::gather][tidyr::spread][tidyr::unnest],
#' `xml2` [xml2::read_html].
#'
#' @importFrom magrittr %>%
#' @importFrom dplyr bind_rows distinct group_split if_else mutate mutate_if select starts_with
#' @importFrom purrr map map_dfr
#' @importFrom rlang !!! set_names syms
#' @importFrom rvest html_nodes html_table
#' @importFrom tibble as_tibble
#' @importFrom tidyr fill gather spread unnest
#' @importFrom xml2 read_html
#' @importFrom htmltools HTML
#' @importFrom stats
#' @importFrom var
#'
#' @export
#'
#### extract_table function ====
extract_html_table <- function(.html, ...) {

  raw <- read_html(.html)

  combo_raw_tables <- raw %>%
    html_nodes("table") %>%
    html_nodes("table") %>%
    html_table(fill=TRUE) %>%
    lapply(., mutate_if, is.numeric, as.character) %>%
    bind_rows() %>%
    set_names( c("var", "val") )

  tagged_groups_df <- combo_raw_tables %>%
    mutate( group_id = if_else(var == "Id", row_number(), NA_integer_) ) %>%
    fill(group_id)

  tagged_groups_df %>%
    group_split(group_id) %>%
    map(spread, var, val) %>%
    map_dfr( gather, "sent_to_key", "sent_to_val", starts_with("Recipients") ) %>%
    mutate(sent_to_val = strsplit(sent_to_val, ")")) %>%
    unnest(sent_to_val) %>%
    mutate(sent_to_val = paste(sent_to_val, ")", sep="")) %>%
    distinct()
}


#### Structure Table as Edgelist ====
extract_edgelist <- function(.df, source, target, ...){
  # roxygen info for later
  #' @importFrom magrittr %>%
  `%>%`       <- magrittr::`%>%`
  #' @importFrom dplyr rename select
  rename <- dplyr::rename
  select <- dplyr::select
  #' @importFrom rlang !!! set_names syms
  `!!!`       <- rlang::`!!!`
  set_names   <- rlang::set_names
  syms        <- rlang::syms

  if (!is.data.frame(.df)) {
    print("The object provided is not a data.frame.")
  }
  if (nrow(.df) == 0L) {
    print("Data frame at provided has 0 rows.")
  }
  if (ncol(.df) == 0L) {
    print("Data frame at provided has 0 columns.")
  }
  if (missing(source)){
    print("You have not specified the source column.")
  }
  if (missing(target)){
    print("You have not specified the target column.")
  }
  if(!source %in% colnames(.df))
  {
    print("The selected source is not present in the data.frame")
  }
  if(!target %in% colnames(.df))
  {
    print("The selected target is not present in the data.frame")
  }

  out_cols <- syms(c(source, target))

  out <- .df %>%
    select(!!!out_cols) %>%
    set_names( c("source", "target") )
}
