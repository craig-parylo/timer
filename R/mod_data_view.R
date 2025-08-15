#' data_view UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd
#'
#' @importFrom shiny NS tagList
mod_data_view_ui <- function(id) {
  ns <- NS(id)
  tagList(
    bslib::card(
      bslib::card_header("Data view"),
      bslib::layout_sidebar(
        fillable = TRUE,

        ## sidebar ----
        sidebar = bslib::sidebar(
          shinyWidgets::radioGroupButtons(
            inputId = ns("timescale"),
            choices = NA,
            direction = "vertical"
          )
        ),

        ## main ----
        toastui::datagridOutput(outputId = ns("data_view"))
      ) # end sidebar
    ) # end card
  ) # end tag list
}

#' data_view Server Functions
#'
#' @noRd
mod_data_view_server <- function(id, r) {
  moduleServer(id, function(input, output, session) {
    ns <- session$ns

    # # update the choices for how much data to show
    shiny::observeEvent(r$project_added, {
      r$project_added <- FALSE

      shinyWidgets::updateRadioGroupButtons(
        inputId = "timescale",
        choices = get_timescales_list()
      )
    })

    # update the data displayed whenever the timescale changes
    shiny::observeEvent(input$timescale, {
      output$data_view <-
        toastui::renderDatagrid(
          expr = make_data_view(.id_value = input$timescale)
        )
    })

    # function to create a data view object
    make_data_view <- function(.id_value) {
      # work out the timescale for the requested data
      len_id <- nchar(.id_value)

      # NB, date id values are 8 characters long, week id values are 6
      if (len_id == 1) {
        df <- get_timer_records_for_table()
      } else if (len_id == 8) {
        df <- get_timer_records_for_table(.id_date = .id_value)
      } else if (len_id == 6) {
        df <- get_timer_records_for_table(.id_week = .id_value)
      }

      # create the data view
      dataview <-
        toastui::datagrid(
          data = df,
          colwidths = "auto"
          #filters = TRUE
        ) |>
        toastui::grid_filters(
          columns = "title",
          type = "select"
        ) |>
        toastui::grid_format(
          column = "start",
          formatter = scales::label_date(format = "%Y-%m-%d %H:%M:%S")
        ) |>
        toastui::grid_format(
          column = "end",
          formatter = scales::label_date(format = "%Y-%m-%d %H:%M:%S")
        )
    }
  })
}

## To be copied in the UI
# mod_data_view_ui("data_view_1")

## To be copied in the server
# mod_data_view_server("data_view_1")

# testing module
ui <- bslib::page_fluid(
  mod_data_view_ui("data_view_1")
)
server <- function(input, output, session) {
  mod_data_view_server("data_view_1")
}
shiny::shinyApp(ui, server)
