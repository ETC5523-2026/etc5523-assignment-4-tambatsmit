#' Run the electricity mix app
#'
#' Launches a Shiny app that helps an energy policy analyst compare how
#' quickly countries are changing where their electricity comes from. The
#' app uses [electricity_mix] and [share_change()].
#'
#' @return No return value; called for its side effect of launching the app.
#' @importFrom bslib bs_theme
#' @importFrom ggplot2 ggplot
#' @importFrom ggrepel geom_text_repel
#' @importFrom scales label_percent
#' @export
run_app <- function() {
  app_dir <- system.file("app", package = "powershift")
  shiny::runApp(app_dir)
}
