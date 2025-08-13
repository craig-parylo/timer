#' The application server-side
#'
#' @param input,output,session Internal parameters for {shiny}.
#'     DO NOT REMOVE.
#' @import shiny
#' @noRd
app_server <- function(input, output, session) {

  # functions
  #source(here::here('R', 'utility_functions.R')) # generalised functions
  #source(here::here('R', 'db_controller.R'))     # database controller functions

  # module calls
  mod_current_timer_server("current_timer_1")

  # Your application server logic

  output$timer_calendar <- toastui::renderCalendar({
    toastui::calendar(
      # toastui::cal_demo_data("week"),
      # generate_time_entries() |> 
      #   dplyr::left_join(
      #     y = generate_projects() |> 
      #       dplyr::select(id, title = name),
      #     by = dplyr::join_by("calendarId" == "id")
      #   ),
      get_timer_records_for_calendar(),
      navigation = TRUE,
      view = "week",
      defaultDate = Sys.Date(),
      useCreationPopup = TRUE,
      isReadOnly = FALSE
    ) |> 
      toastui::cal_week_options(
        startDayOfWeek = 1,
        workweek = FALSE,
        narrowWeekend = TRUE,
        showNowIndicator = TRUE,
        eventView = "time"
      ) |> 
      toastui::cal_timezone(
        timezoneName = "Europe/London"
      ) |> 
      toastui::cal_props(
        # generate_projects() 
        get_project_records_for_calendar()
          # dplyr::mutate(
          #   color = "black",
          #   borderColor = "black",
          #   dragBackgroundColor = "black"
          # )
      )
      # toastui::cal_props(
      #   list(
      #     id = 1,
      #     name = "PERSO",
      #     color = "white",
      #     bgColor = "firebrick",
      #     borderColor = "firebrick"
      #   ),
      #   list(
      #     id = 2,
      #     name = "WORK",
      #     color = "white",
      #     bgColor = "forestgreen",
      #     borderColor = "forestgreen"
      #   )
      # )
  })

  output$dates <- shiny::renderPrint({
    input$timer_calendar_dates
  })

  output$click <- shiny::renderPrint({
    input$timer_calendar_click
  })

  # current timer

  # calendar observers
  shiny::observeEvent(input$timer_calendar_add, {
    # str(input$timer_calendar_add)
    toastui::cal_proxy_add("timer_calendar", input$timer_calendar_add)
  })

  shiny::observeEvent(input$timer_calendar_update, {
    # str(input$timer_calendar_update)
    toastui::cal_proxy_update("timer_calendar", input$timer_calendar_update)
  })

  shiny::observeEvent(input$timer_calendar_delete, {
    # str(input$timer_calendar_delete)
    toastui::cal_proxy_delete("timer_calendar", input$timer_calendar_delete)
  })
}


generate_projects <- function() {
  df_return <- tibble::tribble(
    ~id, ~name,  ~colour,
    "1", "Non-chargeable activity", "#55efc4",
    "2", "Home Line Management", "#81ecec",
    "3", "Training and Development", "#74b9ff",
    "4", "Key worker", "#a29bfe",
    "5", "Talking Therapies", "#fd79a8"
  ) |> 
    dplyr::mutate(
      backgroundColor = colour |> grDevices::adjustcolor(alpha.f = 0.2),
      borderColor = colour,
      color = "black"
    )
}

generate_time_entries <- function() {
  df_return <- tibble::tribble(
    ~calendarId, ~start, ~end,
    "4", "2025-08-06 16:02:00", "2025-08-06 17:33:00",
    "1", "2025-08-06 15:00:00", "2025-08-06 16:02:00",
    "2", "2025-08-06 14:00:00", "2025-08-06 15:00:00",
    "4", "2025-08-06 11:30:00", "2025-08-06 12:02:00",
    "5", "2025-08-06 11:00:00", "2025-08-06 11:30:00",
    "3", "2025-08-06 08:29:00", "2025-08-06 11:00:00",
    "1", "2025-08-06 07:32:00", "2025-08-06 08:29:00",
    "5", "2025-08-05 17:34:00", "2025-08-05 18:48:00",
    "5", "2025-08-05 16:46:00", "2025-08-05 17:22:00",
    "5", "2025-08-05 15:40:00", "2025-08-05 16:37:00",
    "5", "2025-08-05 13:29:00", "2025-08-05 14:53:00",
    "4", "2025-08-05 11:02:00", "2025-08-05 12:00:00",
    "3", "2025-08-05 08:43:00", "2025-08-05 11:02:00",
    "4", "2025-08-05 08:25:00", "2025-08-05 08:42:00",
    "1", "2025-08-05 07:08:00", "2025-08-05 08:05:00"
  )
}
