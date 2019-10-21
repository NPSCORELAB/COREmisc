#' @title Application Launcher
#'
#' @author Brendan Knapp, \email{brendan.knapp@@nps.edu}
#'
#' @param .app name of application.
#' @param .use_browser logical.
#'
#' @importFrom shiny runApp
#'
#' @export
launch_shiny_app <- function(.app = "relational_data_structure",
                             .use_browser = TRUE) {
  dir <- system.file("ShinyApp",
                     .app,
                     package = "COREmisc")

  runApp(appDir = dir,
         launch.browser = .use_browser)
}
