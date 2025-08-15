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

# generate_projects <- function() {
#   df_return <- tibble::tribble(
#     ~id, ~name,  ~colour,
#     "1", "Non-chargeable activity", "#55efc4",
#     "2", "Home Line Management", "#81ecec",
#     "3", "Training and Development", "#74b9ff",
#     "4", "Key worker", "#a29bfe",
#     "5", "Talking Therapies", "#fd79a8"
#   ) |>
#     dplyr::mutate(
#       backgroundColor = colour |> grDevices::adjustcolor(alpha.f = 0.2),
#       borderColor = colour,
#       color = "black"
#     )
# }

# generate_time_entries <- function() {
#   df_return <- tibble::tribble(
#     ~calendarId, ~start, ~end,
#     "4", "2025-08-06 16:02:00", "2025-08-06 17:33:00",
#     "1", "2025-08-06 15:00:00", "2025-08-06 16:02:00",
#     "2", "2025-08-06 14:00:00", "2025-08-06 15:00:00",
#     "4", "2025-08-06 11:30:00", "2025-08-06 12:02:00",
#     "5", "2025-08-06 11:00:00", "2025-08-06 11:30:00",
#     "3", "2025-08-06 08:29:00", "2025-08-06 11:00:00",
#     "1", "2025-08-06 07:32:00", "2025-08-06 08:29:00",
#     "5", "2025-08-05 17:34:00", "2025-08-05 18:48:00",
#     "5", "2025-08-05 16:46:00", "2025-08-05 17:22:00",
#     "5", "2025-08-05 15:40:00", "2025-08-05 16:37:00",
#     "5", "2025-08-05 13:29:00", "2025-08-05 14:53:00",
#     "4", "2025-08-05 11:02:00", "2025-08-05 12:00:00",
#     "3", "2025-08-05 08:43:00", "2025-08-05 11:02:00",
#     "4", "2025-08-05 08:25:00", "2025-08-05 08:42:00",
#     "1", "2025-08-05 07:08:00", "2025-08-05 08:05:00"
#   )
# }
