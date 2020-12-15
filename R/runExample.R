#' Run iCodon example
#'
#' Launch a Shiny app that shows a demo of what can be done with
#' \code{iCodon::optimizer}.
#'
#' This example is also: TODO: add the link to the shyny app
#' \href{http://daattali.com/shiny/ggExtra-ggMarginal-demo/}{available online}.
#'
#' @examples
#' ## Only run this example in interactive R sessions
#' if (interactive()) {
#'   runExample()
#' }
#' @export
runExample <- function() {
  appDir <- system.file("shiny-examples", "iCodon", package = "iCodon")
  if (appDir == "") {
    stop("Could not find example directory. Try re-installing `iCodon`.",
      call. = FALSE
    )
  }

  shiny::runApp(appDir, display.mode = "normal")
}
