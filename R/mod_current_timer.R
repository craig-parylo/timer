#' current_timer UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd
#'
#' @importFrom shiny NS tagList
mod_current_timer_ui <- function(id) {
  ns <- NS(id)
  tagList(
    bslib::card(
      bslib::card_header("Current timer"),
      bslib::card_body(
        fillable = FALSE,
        bslib::layout_column_wrap(
          fixed_width = FALSE,
          shiny::selectizeInput(
            inputId = ns("current_project"),
            label = "Project",
            choices = NA,
            multiple = FALSE
          ),

          shiny::actionButton(
            inputId = ns("start_stop_timer"),
            label = "Start timer"
          ),

          shiny::textOutput(
            outputId = ns("duration")
          )
        ) # end of container
      )
    )
  )
}

#' current_timer Server Functions
#'
#' @noRd
mod_current_timer_server <- function(id, r) {
  moduleServer(id, function(input, output, session) {
    ns <- session$ns

    # initialise the reactive values
    current <- shiny::reactiveValues(
      start_time = NA,
      end_time = NA,
      duration = NA,
      running = FALSE
    )

    # prepare

    # respond to button clicks
    shiny::observeEvent(input$start_stop_timer, {
      if (current$running) {
        # stop the timer
        current$end_time <- lubridate::now()

        # update the action button
        current$running <- FALSE
        shiny::updateActionButton(
          session = session,
          inputId = "start_stop_timer",
          label = "Start timer"
        )

        # record the timer in the database
        add_timer_record(
          project_id = input$current_project,
          start = current$start_time |> lubridate::as_datetime(),
          end = current$end_time |> lubridate::as_datetime(),
          body = ""
        )

        # update the global reactive values
        r$timer_added <- TRUE
      } else {
        # start the timer
        current$start_time <- lubridate::now()
        current$running <- TRUE
        shiny::updateActionButton(
          session = session,
          inputId = "start_stop_timer",
          label = "Stop timer"
        )
      }
    })

    # reactive timer to display the duration
    auto_invalidate <- shiny::reactiveTimer(1e3L) # update every 1,000 miliseconds (1 second)

    # display how long the timer has been running
    output$duration <- shiny::renderText({
      auto_invalidate() # trigger the timer

      if (current$running) {
        # calculate the current duration
        time_taken <- calculate_duration(
          .start_time = current$start_time |>
            lubridate::round_date(unit = "second"),
          .end_time = lubridate::now() |> lubridate::round_date(unit = "second")
        ) |>
          as.character()

        # use the value
        time_taken
      } else {
        "Timer not running yet"
      }
    })

    # update the list of projects
    shiny::observeEvent(r$project_added, {
      shiny::updateSelectizeInput(
        inputId = "current_project",
        choices = get_project_choices()
      )
    })
  }) # end of module server
}

## To be copied in the UI
# mod_current_timer_ui("current_timer_1")

## To be copied in the server
# mod_current_timer_server("current_timer_1")

# testing module
ui <- bslib::page_fluid(
  mod_current_timer_ui("current_timer_1")
)
server <- function(input, output, session) {
  mod_current_timer_server("current_timer_1")
}
shiny::shinyApp(ui, server)
