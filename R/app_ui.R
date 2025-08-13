#' The application User-Interface
#'
#' @param request Internal parameter for `{shiny}`.
#'     DO NOT REMOVE.
#' @import shiny
#' @noRd
app_ui <- function(request) {
  tagList(
    # Leave this function for adding external resources
    golem_add_external_resources(),
    
    # Your application UI logic
    bslib::page_sidebar(
      title = "timeR",

      # sidebar controls ----
      sidebar = bslib::sidebar(
        open = "closed"
      ),

      # main content ----
      ## current ----
      # bslib::card(
      #   bslib::card_header("Timer"),
      #   bslib::card_body(
      #     shiny::actionButton(
      #       inputId = "start_timer",
      #       label = "Start",
      #     ),
      #     shiny::textOutput(
      #       outputId = "start_time_label"
      #     ),
      #     shiny::actionButton(
      #       inputId = "stop_timer",
      #       label = "Stop"
      #     )
      #   )
      # ),
      # call the module ui
      mod_current_timer_ui("current_timer_1"),

      ## navset ----
      bslib::navset_card_underline(

        ### nav calendar ----
        bslib::nav_panel(
          title = "Calendar",
          toastui::calendarOutput(outputId = "timer_calendar", height = "90%")
        ),

        ### nav timesheet ----
        bslib::nav_panel(
          title = "Timesheet",
          shiny::p("Placeholder for timesheet")
        )
      ),

      # bslib::card(
      #   bslib::card_header("Calendar"),
      #   toastui::calendarOutput(outputId = "timer_calendar", height = "90%")
      # ),

      # bslib::card(
      #   bslib::card_title("Dates"),
      #   shiny::verbatimTextOutput("dates")
      # ),

      # bslib::card(
      #   bslib::card_title("Clicked schedule"),
      #   shiny::verbatimTextOutput("click")
      # )
    )

    # fluidPage(
    #   golem::golem_welcome_page() # Remove this line to start building your UI
    # )
  )
}

#' Add external Resources to the Application
#'
#' This function is internally used to add external
#' resources inside the Shiny application.
#'
#' @import shiny
#' @importFrom golem add_resource_path activate_js favicon bundle_resources
#' @noRd
golem_add_external_resources <- function() {
  add_resource_path(
    "www",
    app_sys("app/www")
  )

  tags$head(
    favicon(),
    bundle_resources(
      path = app_sys("app/www"),
      app_title = "timer"
    )
    # Add here other external resources
    # for example, you can add shinyalert::useShinyalert()
  )
}
