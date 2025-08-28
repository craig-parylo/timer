#' The application server-side
#'
#' @param input,output,session Internal parameters for {shiny}.
#'     DO NOT REMOVE.
#' @import shiny
#' @noRd
app_server <- function(input, output, session) {
  # app-wide reactive values
  r <- shiny::reactiveValues(
    timer_added = TRUE, # initialise the value
    project_added = TRUE
  )

  # module calls
  mod_current_timer_server("current_timer_1", r = r)
  mod_calendar_view_server("calendar_view_1", r = r)
  mod_data_view_server("data_view_1", r = r)

  # Your application server logic
}
