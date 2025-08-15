#' calendar_view UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd
#'
#' @importFrom shiny NS tagList
mod_calendar_view_ui <- function(id) {
  ns <- NS(id)
  tagList(
    toastui::calendarOutput(
      outputId = ns("timer_calendar"),
      height = "90%"
    )
  )
}

#' calendar_view Server Functions
#'
#' @noRd
mod_calendar_view_server <- function(id, r) {
  moduleServer(id, function(input, output, session) {
    ns <- session$ns

    # output$timer_calendar <-
    #   toastui::renderCalendar({
    #     # create a calendar view
    #     toastui::calendar(
    #       get_timer_records_for_calendar(), # using records from the database
    #       navigation = TRUE,
    #       view = "week",
    #       defaultDate = Sys.Date(),
    #       useCreationPopup = FALSE,
    #       isReadOnly = TRUE
    #     ) |>
    #       # define some options for the 'week' view
    #       toastui::cal_week_options(
    #         startDayOfWeek = 1,
    #         workweek = FALSE,
    #         narrowWeekend = FALSE,
    #         showNowIndicator = TRUE,
    #         eventView = "time"
    #       ) |>
    #       # set the timezone
    #       # toastui::cal_timezone(timezoneName = "Europe/London") |>
    #       # define properties for projects, such as colours and titles
    #       toastui::cal_props(
    #         get_project_records_for_calendar()
    #       )
    #   })

    # functions
    get_calendar <- function() {
      cal <-
        # prepare a calendar
        toastui::calendar(
          data = get_timer_records_for_calendar(), # using records from the database
          navigation = TRUE,
          view = "week",
          defaultDate = Sys.Date(),
          useCreationPopup = FALSE,
          isReadOnly = TRUE
        ) |>
        # define some options for the 'week' view
        toastui::cal_week_options(
          startDayOfWeek = 1,
          workweek = FALSE,
          narrowWeekend = FALSE,
          showNowIndicator = TRUE,
          eventView = "time"
        ) |>
        # define properties for projects, such as colours and titles
        toastui::cal_props(get_project_records_for_calendar())

      return(cal)
    }

    # reactives
    # calendar_reactive <-
    #   shiny::reactive({

    #     # only complute when running is TRUE
    #     #req(!current$running)
    #     #req(ns(!current$running))

    #     # only update when timer_added is TRUE
    #     req(r$timer_added)

    #     print("calendar_reactive called")

    #     # reset the global reactiveValues
    #     r$timer_added <- FALSE

    #     # prepare a calendar
    #     cal <- get_calendar()

    #     # return this calendar
    #     return(cal)
    #   })

    # testing observer
    shiny::observeEvent(r$timer_added, {
      r$timer_added <- FALSE

      output$timer_calendar <-
        toastui::renderCalendar({
          get_calendar()
        })
    })

    # calendar observers
    shiny::observeEvent(input$timer_calendar_add, {
      toastui::cal_proxy_add("timer_calendar", input$timer_calendar_add)
    })

    shiny::observeEvent(input$timer_calendar_update, {
      toastui::cal_proxy_update("timer_calendar", input$timer_calendar_update)
    })

    shiny::observeEvent(input$timer_calendar_delete, {
      toastui::cal_proxy_delete("timer_calendar", input$timer_calendar_delete)
    })

    # outputs
    # output$timer_calendar <-
    #   toastui::renderCalendar({
    #     calendar_reactive()
    #   })
  })
}

## To be copied in the UI
# mod_calendar_view_ui("calendar_view_1")

## To be copied in the server
# mod_calendar_view_server("calendar_view_1")

# testing module
ui <- bslib::page_fillable(
  bslib::card_body(
    mod_calendar_view_ui("calendar_view_1")
  )
)
server <- function(input, output, session) {
  mod_calendar_view_server("calendar_view_1")
}
shiny::shinyApp(ui, server)
