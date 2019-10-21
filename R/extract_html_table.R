#' @keywords internal
#'
#' @title Get HTML
#' @param file_path the location and name of the file which the data are to be read from.
#' @param ... Extra arguments to pass.
#'
#' @importFrom htmltools HTML
#' @importFrom xml2 read_html
#'
get_html <- function(file_path) {
  #stopifnot(file.exists(file_path))
  read_html( HTML( file_path ) )
}

#' @title Extract Direct Shares Table
#'
#' @description `extract_shares` returns a `data.frame` with the values in the HTML.
#'
#' @author Christopher Callaghan, \email{cjcallag@@nps.edu}
#' @author Brendan Knapp, \email{brendan.knapp@@nps.edu}
#'
#' @param .html An `HTML` file from each information request.
#' @param ... Extra arguments to pass.
#'
#' @importFrom magrittr %>%
#' @importFrom dplyr mutate_if bind_rows mutate if_else row_number group_split starts_with
#' @importFrom purrr map map_dfr
#' @importFrom rlang set_names
#' @importFrom rvest html_nodes html_table
#' @importFrom tidyr fill gather spread unnest
#' @importFrom lubridate ymd_hms with_tz
#'
#' @export
extract_shares <- function(.html, ...) {
  combo_raw_tables <- .html %>%
    html_nodes("table") %>%
    html_nodes("table") %>%
    html_table(fill=TRUE) %>%
    lapply(., mutate_if, is.numeric, as.character) %>%
    bind_rows() %>%
    set_names( c("var", "val") )

  tagged_groups_df <- combo_raw_tables %>%
    mutate( group_id = if_else(var == "Id",
                               row_number(),
                               NA_integer_) ) %>%
    fill(group_id)

  tagged_groups_df %>%
    group_split(group_id) %>%
    map(spread, var, val) %>%
    map_dfr( gather, "sent_to_key", "sent_to_val", starts_with("Recipients") ) %>%
    mutate(sent_to_val = strsplit(sent_to_val, ")")) %>%
    unnest(sent_to_val) %>%
    mutate(sent_to_val = paste(sent_to_val, ")", sep=""),
           Time_tz = ymd_hms(Time) %>%
             with_tz(tzone = Sys.timezone())) %>%
    distinct()
}

#' @title Extract Direct Stories Table
#'
#' @description `extract_stories` returns a `data.frame` with the values in the HTML.
#'
#' @author Christopher Callaghan, \email{cjcallag@@nps.edu}
#' @author Brendan Knapp, \email{brendan.knapp@@nps.edu}
#'
#' @param .html An `HTML` file from each information request.
#' @param ... Extra arguments to pass.
#'
#' @importFrom magrittr %>%
#' @importFrom dplyr bind_rows distinct group_split if_else mutate mutate_if row_number select starts_with
#' @importFrom purrr map map_dfr
#' @importFrom rlang set_names
#' @importFrom rvest html_nodes html_table
#' @importFrom tidyr fill gather spread unnest
#' @importFrom lubridate ymd_hms with_tz
#'
#' @export
extract_stories <- function(.html, ...) {
  combo_raw_tables <- .html %>%
    html_nodes("table") %>%
    html_nodes("table") %>%
    html_table(fill=TRUE) %>%
    lapply(., mutate_if, is.numeric, as.character) %>%
    bind_rows() %>%
    set_names( c("var", "val") )

  tagged_groups_df <- combo_raw_tables %>%
    mutate( group_id = if_else(var == "Media Id",
                               row_number(),
                               NA_integer_) ) %>%
    fill(group_id)

  tagged_groups_df %>%
    group_split(group_id) %>%
    map(spread, var, val) %>%
    map_dfr( gather, "sent_to_key", "sent_to_val", starts_with("Recipients") ) %>%
    mutate(sent_to_val = strsplit(sent_to_val, ")")) %>%
    unnest(sent_to_val) %>%
    mutate(sent_to_val = paste(sent_to_val, ")", sep=""),
           Time_tz = lubridate::ymd_hms(Time) %>%
             lubridate::with_tz(tzone = Sys.timezone())) %>%
    distinct()
}

#' @title Extract Followship Table
#'
#' @description `extract_followship` returns a `data.frame` with the values in the HTML.
#'
#' @author Christopher Callaghan, \email{cjcallag@@nps.edu}
#' @author Brendan Knapp, \email{brendan.knapp@@nps.edu}
#'
#' @param .html An `HTML` file from each information request.
#' @param ... Extra arguments to pass.
#'
#' @importFrom magrittr %>%
#' @importFrom dplyr mutate_if bind_rows select
#' @importFrom rlang set_names
#' @importFrom rvest html_nodes html_table
#' @importFrom stringr str_split
#' @importFrom tidyr unnest
#'
#' @export
extract_followship <- function(.html, ...) {
  raw_followers <- .html %>%
    html_nodes("table") %>%
    html_table(fill=TRUE) %>%
    lapply(., mutate_if, is.numeric, as.character) %>%
    bind_rows() %>%
    set_names( c("var", "val") ) %>%
    select(val) %>%
    mutate(followers = str_split(
      val, "\r\n\r\n")) %>%
    unnest() %>%
    select(followers)

  raw_followers
}

#' @title Extract Edgelist
#'
#' @description `extract_edgelist` returns a `data.frame` edgelist from other tables extracted from HTML returns.
#'
#' @author Christopher Callaghan, \email{cjcallag@@nps.edu}
#'
#' @param .df a \code{data.frame} for parsing.
#' @param .source variable name to select as source
#' @param .target variable name to select as target
#' @param ... Extra arguments to pass.
#'
#' @importFrom magrittr %>%
#' @importFrom dplyr select
#' @importFrom rlang !!! set_names syms
#'
#' @export
extract_edgelist <- function(.df, .source, .target, ...){
  if (!is.data.frame(.df)) {
    stop("The object provided is not a data.frame.", call. = FALSE)
  }
  if(!.source %in% colnames(.df)) {
    stop("The selected source is not present in the data frame", call. = FALSE)
  }
  if(!.target %in% colnames(.df)) {
    print("The selected target is not present in the data.frame")
  }

  out_cols <- syms(c(.source, .target))

  out <- .df %>%
    select(!!!out_cols) %>%
    set_names( c("source", "target") )
  out
}
