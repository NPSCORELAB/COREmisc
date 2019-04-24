#' @export
launch_shiny_app <- function(.app = "relational_data_structure",
                             .use_browser = TRUE) {
  dir <- system.file("ShinyApp", .app, package = "COREmisc")

  shiny::runApp(appDir = dir, launch.browser = .use_browser)
}
