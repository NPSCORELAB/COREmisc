#' @title Find IP address geolocation
#'
#' @description `find_ip` returns a `data.frame` with geolocated IP addresses.
#'
#' @author Christopher Callaghan, \email{cjcallag@@nps.edu}
#'
#' @param .df, A `data.frame` object with ip address in a column named `Sender_IP`
#'
#' @examples
#' library(COREmisc)
#' df <- read.csv(file.choose())
#' out_table <- COREmisc::find_ip(df)
#'
#' @seealso Uses funcitons from `magrittr` [magrittr::`%>%`],
#' `dplyr` [dplyr::left_join][dplyr::distinct]
#'
#' @importFrom magrittr %>%
#' @importFrom dplyr left_join distinct
#' @importFrom ipapi geolocate
#'
#' @export
find_ip <- function(.df, ...) {
  if("Sender_IP" %in% colnames(.df)){
    geolocated <- ipapi::geolocate(.df$Sender_IP, .progress = TRUE)

    .df %>%
      left_join(geolocated, by=c("Sender_IP"="query")) %>%
      distinct() -> out
    return(out)
  }
  else{
    stop("No `Sender_IP` variable found in dataset provided.", call. = FALSE)
  }
}
