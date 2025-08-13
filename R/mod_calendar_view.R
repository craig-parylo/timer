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
 
  )
}
    
#' calendar_view Server Functions
#'
#' @noRd 
mod_calendar_view_server <- function(id){
  moduleServer(id, function(input, output, session){
    ns <- session$ns
 
  })
}
    
## To be copied in the UI
# mod_calendar_view_ui("calendar_view_1")
    
## To be copied in the server
# mod_calendar_view_server("calendar_view_1")
