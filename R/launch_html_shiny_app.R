#' @export
launch_html_shiny_app <- function(.app = "html_table_structure",
                             .use_browser = TRUE) {
  dir <- system.file("ShinyApp", .app, package = "COREmisc")

  shiny::runApp(appDir = dir, launch.browser = .use_browser)
}
