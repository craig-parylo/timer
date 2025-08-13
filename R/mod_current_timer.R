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
        
        shiny::actionButton(
          inputId = ns("start_stop_timer"),
          label = "Start timer"
        ),

        shiny::textOutput(
          outputId = ns("start_time_label")
        ),
        shiny::textOutput(
          outputId = ns("stop_time_label"),
        ),
        shiny::textOutput(
          outputId = ns("duration")
        )
      )
    )
  )
}
    
#' current_timer Server Functions
#'
#' @noRd 
mod_current_timer_server <- function(id){
  moduleServer(id, function(input, output, session){
    ns <- session$ns

    # initialise the reactive values
    current <- shiny::reactiveValues(
      start_time = NA,
      end_time = NA,
      duration = NA,
      running = FALSE
    )

    # respond to button clicks
    shiny::observeEvent(input$start_stop_timer, {
      if (current$running) {

        # stop the timer
        current$end_time <- lubridate::now()
        current$running <- FALSE
        shiny::updateActionButton(
          session = session,
          inputId = "start_stop_timer",
          label = "Start timer"
        )

        # # calculate the elapsed time
        # time_taken <- lubridate::as.period(
        #   lubridate::interval(
        #     start = current$start_time |> lubridate::ymd_hms(),
        #     end = current$end_time |> lubridate::ymd_hms()
        #   )
        # )


        # update the reactive value
        #current$duration <- time_taken |> as.character()

        # update the labels
        # output$stop_time_label <- shiny::renderText(current$end_time)
        # output$duration <- shiny::renderText(current$duration)

        # record this time
        add_timer_record(
          project_id = 1,
          start = current$start_time |> lubridate::as_datetime(),
          end = current$end_time |> lubridate::as_datetime(),
          body = ""
        )

      } else {

        # start the timer
        current$start_time <- lubridate::now() 
        current$running <- TRUE
        shiny::updateActionButton(
          session = session,
          inputId = "start_stop_timer",
          label = "Stop timer"
        )

        # update the start time label
        output$start_time_label <- shiny::renderText(current$start_time |> format("%Y-%m-%d %H:%M:%S"))

      }
    })

    # reactive timer to display the duration
    auto_invalidate <- shiny::reactiveTimer(1e3L) # update every 1,000 miliseconds (1 second)

    # display how long the timer has been running
    output$duration <- shiny::renderText({
      auto_invalidate() # trigger the timer

      if (current$running) {

        # calculate the duration
        time_taken <- 
          lubridate::as.period(
            lubridate::interval(
              start = current$start_time |> lubridate::round_date(unit = "second"),
              end = lubridate::now() |> lubridate::round_date(unit = "second")
            ) 
          ) |> 
          as.character()
        
        # use the value
        time_taken

      } else {
        "Timer not running yet"
      }
      
    })
  })
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