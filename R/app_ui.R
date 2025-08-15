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
    bslib::page_fillable(
      title = "timeR",

      # # sidebar controls ----
      # sidebar = bslib::sidebar(
      #   open = "closed",
      #   bslib::side
      # ),

      # main content ----

      ## current ----
      # call the 'current timer' module ui
      mod_current_timer_ui("current_timer_1"),

      ## navset ----
      bslib::navset_card_underline(
        ### nav calendar ----
        bslib::nav_panel(
          title = "Calendar",
          # call the 'calendar view' module ui
          mod_calendar_view_ui("calendar_view_1")
        ),

        ### nav timesheet ----
        bslib::nav_panel(
          title = "Timesheet",
          shiny::p("Placeholder for timesheet")
        ),

        ### nav data ----
        bslib::nav_panel(
          title = "Data",
          #shiny::p("Placeholder for data")
          # call the 'data view' module ui
          mod_data_view_ui("data_view_1")
        )
      )
    )
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
