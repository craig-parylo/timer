#' Check whether a supplied datetime is of POSIXct type
#'
#' @description
#' If the supplied value inherits from the 'POSIXct' data type then it is
#' returned, otherwise the function call is aborted and console error raised.
#'
#' @param datetime_value Input expected to be of POSIXct type
#'
#' @returns POSIXct datetime_value or an error raised
#' @examples
#' # if the parameter is valid POSIXct then it is returned
#' check_datetime(as.POSIXct("2025-08-12 08:00:00"))
#'
#' # if the parameter is not a valid POSIXct value then an error is returned
#' check_datetime("2025-08-12 08:00:00")

check_datetime <- function(datetime_value) {
  # check if the input is of class POSIXct
  if (!inherits(datetime_value, "POSIXct")) {
    cli::cli_abort("The input must be a datetime value of class POSIXct")
  }
  # if the check passes, return the datetime value
  return(datetime_value)
}

#' Calculate the duration between two time periods
#'
#' @description
#' Calculates the duration between two time periods.
#'
#' @details
#' Uses functions from the lubridate package to first calculate the `interval`,
#' which is defined as 'time spans bound by two real date-times', which are
#' rounded to the nearest second, before being converted to a `period` to
#' report the elapsed time using the appropriate units, e.g. 1H 18M 0S.
#'
#' @param .start_time POSIXct datetime - the start of the time period
#' @param .end_time POSIXct datetime - the end of the time period
#'
#' @returns Numeric, double - a lubridate `period` object
#'
#' @export
#' @examples
#' calculate_duration(
#'   .start_time = lubridate::as_datetime("2025-08-13 07:16:00"),
#'   .end_time = lubridate::as_datetime("2025-08-13 08:34:00")
#' )
calculate_duration <- function(.start_time, .end_time) {
  # validate the two parameters as POSIXct datetimes
  .start_time <- check_datetime(.start_time)
  .end_time <- check_datetime(.end_time)

  # calculate the time taken as a lubridate period object
  time_taken <-
    lubridate::as.period(
      lubridate::interval(
        start = .start_time |> lubridate::round_date(unit = "second"),
        end = .end_time |> lubridate::round_date(unit = "second")
      )
    )

  # return the value
  return(time_taken)
}

#' Get details for projects ready for use in a select input
#'
#' @description
#' Returns a named list of projects ready for use in a select input
#'
#' @details
#' Gets a tibble of project details from the `get_project_records()` function,
#' limits the details to project name and id values then creates a named list
#' suitable for use with a select input control.
#'
#' @seealso
#' [get_project_records()] To return a tibble of project details
#'
#' @returns List of named projects with the corresponding database id numbers
#'
#' @export
#' @examples
#' get_project_choices()
get_project_choices <- function() {
  # get all project details as a named list
  projects_list <-
    get_project_records() |>
    # limit to just two columns - id and name
    dplyr::select(
      dplyr::all_of(
        c("name", "id")
      )
    ) |>
    # convert to a named list object
    tibble::deframe()

  # return this value
  return(projects_list)
}

#' Get a list of timescales
#'
#' @description
#' Returns a named list of timescales along with the corresponding id value
#' for the day or week for use with the 'data view' module
#'
#' @details
#' Returns a named list of time periods:
#' - 'Today' and 'Yesterday' contain the id values for the corresponding days
#' - 'This week' and 'Last week' contain the id values for the corresponding weeks
#' - 'All' is `NA`.
#'
#' @returns Named list of time periods and corresponding 'id' values
#'
#' @export
#' @examples
#' get_timescales_list()
get_timescales_list <- function() {
  list_return <- list(
    "Today" = get_id_date(lubridate::now()),
    "Yesterday" = get_id_date(lubridate::now() - lubridate::days(1)),
    "This week" = get_id_week(lubridate::now()),
    "Last week" = get_id_week(lubridate::now() - lubridate::weeks(1)),
    "All" = 0
  )

  # return the list
  return(list_return)
}
