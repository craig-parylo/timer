#' Get the database file path
#' 
#' @description
#' Returns the file path to the database
#' 
#' @details
#' An internal function to return the file path to the database, called
#' `timer_db.sqlite` which is stored within the `inst` folder.
#'
#' @returns String - file path to the database file
get_db_path <- function() {
  return(file.path("inst", "timer_db.sqlite"))
}

#' Create and initialise the timer database
#' 
#' @description
#' Creates a {SQLite} database to hold data for the {timeR} application 
#' and initialised for use. 
#' 
#' @details
#' If the database does not exist, then it will be created. 
#' 
#' If the `projects` table does not exist, then it will be created and
#' initialised with common projects, such as 'Non-chargeable time', 'Annual
#' leave' and so on.
#' 
#' If the `timers` table does not exist, then it will be created and indexes
#' created on both the `id_date` and `id_week` columns. As their name indicates
#' these columns are identifier columns used to uniquely identify a day (in 
#' YYYYMMDD notation) and any given week (using YYYYWW notation). These columns
#' are calculated fields and are designed to improve query responsiveness.
#' 
#' @returns NA
#'
#' @export
#' @examples
#' # This function is designed to be called at the beginning of the app, doing
#' # nothing more than checking the necessary database and tables are set up.
#' create_db()
create_db <- function() {

  # set the connection
  con <- DBI::dbConnect(RSQLite::SQLite(), get_db_path())

  # projects ----
  # create the projects table if it doesn't exist
  project_table_exists <- DBI::dbExistsTable(conn = con, name = "projects")

  # if it does not exist then create it and populate with common projects
  if (!project_table_exists) {

    # create the table
    DBI::dbExecute(
      conn = con,
      statement = "CREATE TABLE IF NOT EXISTS projects (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        colour TEXT
      );"
    )

    # set some default projects
    DBI::dbExecute(
      conn = con,
      statement = "INSERT INTO projects (name, colour) VALUES 
      ('Non-chargeable activity', '#7f8fa6'),
      ('Annual leave', '#fbc531'),
      ('Other leave', '#fbc531'),
      ('Training & development', '#1abc9c'),
      ('Prospecting', '#8e44ad'),
      ('Home line management', '#27ae60')
      ;"
    )
  }

  # timers ----
  # create the timers table if it doesn't exist
  timers_table_exists <- DBI::dbExistsTable(conn = con, name = "timers")

  if (!timers_table_exists) {

    # create the table
    DBI::dbExecute(
      conn = con,
      statement = "CREATE TABLE IF NOT EXISTS timers (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        calendarId INTEGER,
        start NUMERIC,
        end NUMERIC,
        body TEXT,
        id_date NUMERIC,
        id_week NUMERIC
      )"
    )

    # set indexes for faster querying
    DBI::dbExecute(
      conn = con,
      statement = "CREATE INDEX id_date_index ON timers(id_date);"
    )
    DBI::dbExecute(
      conn = con,
      statement = "CREATE INDEX id_week_index ON timers(id_week);"
    )
  }

  # disconnect
  DBI::dbDisconnect(con)
}


#' Add a timer record
#' 
#' @description
#' Adds a record to the `timer` database table to record a period of time
#' working on a project.
#' 
#' @details
#' This function handles the insertion of a new record to the `timer` database.
#' Supply the details for which project this activity was conducted for, the 
#' start and end datetimes and, optionally, a description of what work was
#' done, and the function will insert it to the `timers` table of the `timer`
#' database.
#'  
#' @param project_id Integer - the ID for the project to assign this `timer` record to
#' @param start POSIXct datetime - the start date and time for this period of activity 
#' @param end POSIXct datetime - the end date and time for this period of activity
#' @param body String (optional) - a description of the work carried out
#'
#' @returns NA
#'
#' @export
#' @examples
#' add_timer_record(
#'  project_id = 1,
#'  start = as.POSIXct("2025-08-12 12:00:00"),
#'  end = as.POSIXct("2025-08-12 13:47:13"),
#'  body = "Working the {timer} database app"
#' )
add_timer_record <- function(
  project_id,
  start,
  end,
  body = ""
) {

  # check if the supplied `project_id` is valid
  .project_id <- check_project_id(project_id)

  # check if the supplied `start` and `end` datetimes are valid POSIXct values
  .start <- check_datetime(start)
  .end <- check_datetime(end)

  # calculate the id_date and id_week
  .id_date <- get_id_date(.start)
  .id_week <- get_id_week(.start)

  # input seems OK, generate the insert query
  str_query <- "INSERT INTO timers (calendarId, start, end, body, id_date, id_week) VALUES (?, ?, ?, ?, ?, ?);"

  # run the insert query
  tryCatch({
    con <- DBI::dbConnect(RSQLite::SQLite(), get_db_path())

    result <- DBI::dbExecute(
      conn = con,
      statement = str_query,
      params = list(.project_id, .start, .end, body, .id_date, .id_week)
    )

    DBI::dbDisconnect(con)

  }, error = function(e) {
    
    DBI::dbDisconnect(con)
    cli::cli_alert("Record not added!")

  })

}

#' Get a unique ID for the date
#' 
#' @description
#' Generates a numeric ID from a POSIXct datetime that uniquely identifies 
#' the date
#' 
#' @details
#' Returns an integer which can be used as a unique identifier for the date
#' encoded in the 'datetime' object. 
#' 
#' It works by first formatting the datetime to a string with the format 
#' YYYYMMDD then casting to numeric type.
#'
#' @param datetime POSIXct datetime
#'
#' @returns Numeric - an eight digit number used as an id number for the date
#'
#' @export
#' @examples
#' get_id_date(as.POSIXct("2025-08-12 12:00:00"))
#' get_id_date(lubridate::now())

get_id_date <- function(datetime) {
  # check the datetime is valid
  datetime <- check_datetime(datetime)

  # format as a unique ID number for the day
  int_return <- 
    format.Date(x = datetime, format = "%Y%m%d") |> 
    as.numeric()

  # return the value
  return(int_return)
}

#' Get a unique ID for the week
#' 
#' @description
#' Generates a numeric ID from a POSIXct datetime that uniquely identifies 
#' the week
#' 
#' @details
#' Returns an integer which can be used as a unique identifier for the week
#' encoded in the 'datetime' object.
#' 
#' It uses a combination of the ISO-year and ISO-week from the `lubridate`
#' package to generate an integer that uniquely identifies the week 
#' across years.
#' 
#' It does this by generating the ISO-year, e.g 2025, then multiplying by
#' 100 to move the digits two decimal places, e.g. 202500. Then it adds the
#' ISO week number, e.g. 33 to this to generate an integer, e.g. 202533 that
#' is unique across years.
#'
#' @param datetime POSIXct datetime
#'
#' @returns Numeric - a six digit number used as an id for the week
#'
#' @export
#' @examples
#' get_id_week(as.POSIXct("2025-08-12 12:00:00"))
#' get_id_week(lubridate::now())

get_id_week <- function(datetime) {
  
  # check the datetime is valid
  datetime <- check_datetime(datetime)
  
  # format as a unique ID number for the week
  int_return <-
    (lubridate::isoyear(datetime) * 100 ) + lubridate::isoweek(datetime)
  
  # return the value
  return(int_return)
}

#' Checks for a valid `project_id`
#' 
#' @description
#' Checks whether the supplied `project_id` exists within the `projects` table.
#'
#' @param .input_project_id Numeric - input value to check if exists
#'
#' @returns Numeric - the ID value if it exists as a project_id, otherwise raises an error
check_project_id <- function(input_project_id) {
  
  # set the connection
  con <- DBI::dbConnect(RSQLite::SQLite(), get_db_path())

  # create a SQL query to check for the ID
  str_query <- glue::glue(
    "SELECT COUNT(id) FROM projects WHERE id = {input_project_id};"
  )

  # execute the query
  result <- DBI::dbGetQuery(
    conn = con,
    statement = str_query
  )

  # disconnect
  DBI::dbDisconnect(con)

  # if the result is not greater than zero then raise an error, otherwise return the value
  if (!result[1, 1] > 0) {
    cli::cli_abort("There is no project with {.var input_project_id} of {.val {input_project_id}}")
  } else {
    return(input_project_id)
  }
}

#' Get `timers` records
#' 
#' @description
#' Returns records from the `timers` table that match the supplied id value for 
#' the date or week, or all records if both parameters are empty.
#' 
#' @details
#' Conducts a SELECT query from the `timers` table to return records. If values
#' are supplied for either or both `.id_date` or `.id_week` then the query 
#' returns records for that day or week respectively.
#' 
#' Please note, if both parameters are supplied the query will return the 
#' intersection of the two, so if the date for `.id_date` did not fall within
#' the range of dates for `.id_week` then no results will be returned.
#'
#' @param .id_date Numeric - an ID value that uniquely identifies a date, in the format 'YYYYMMDD', 
#' @param .id_week Numeric - an ID value that uniquely identifies a week, in the format 'YYYYWW'
#'
#' @returns Tibble
#' 
#' @seealso
#' [get_id_date()] for a function that returns an .id_date for a given POSIXct datetime, and
#' [get_id_week()] for a function that reuturns an .id_week for a given POSIXct datetime.
#' [get_project_records()] does a similar function for project records.
#'
#' @export
#' @examples
#' # calling the function with no arguments will return all records
#' get_timer_records()
#' 
#' # calling the function with either .id_date or .id_week will return records for
#' # that date or week, respectively
#' get_timer_records(.id_date = 20250812)
#' get_timer_records(.id_week = 202533)
#' 
#' # if you don't know the id number but have a POSIXct value you can combine it
#' # with the `get_id_date()` or `get_id_week()` helper functions
#' get_timer_records(
#'   .id_week = get_id_week(lubridate::as.datetime("2025-08-13 08:50:00"))
#' )
get_timer_records <- function(
  .id_date = NA,
  .id_week = NA
) {

  # set the connection
  con <- DBI::dbConnect(RSQLite::SQLite(), get_db_path())

  # create a SQL query to check for the ID
  str_query <- "SELECT * FROM timers WHERE (id_date = ? OR ? IS NULL) AND (id_week = ? OR ? IS NULL);"

  # execute the query
  result <- DBI::dbGetQuery(
    conn = con,
    statement = str_query,
    params = list(.id_date, .id_date, .id_week, .id_week)
  )

  # disconnect
  DBI::dbDisconnect(con)

  # return the result
  return(tibble::as_tibble(result))

}


#' Get `projects` records
#' 
#' @description
#' Returns records from the `projects` table that match the supplied id for the
#' project, or all records if the parameter is empty.
#' 
#' @details
#' Conducts a SELECT query from the `projects` table to return records. If a 
#' value is supplied for `.id_project` then the query returns the record for
#' that project.
#'
#' @param .id_project Numeric - an ID value that uniquely identifies a project
#'
#' @returns Tibble of project records
#'
#' @export
#' @examples
#' # calling the function with no arguments will return all records
#' get_project_records()
#' 
#' # calling the function with an .id_project will return the record for that
#' # project
#' get_project_records(.id_project = 1)
#' ---
get_project_records <- function(
  .id_project = NA
) {
  
  # set the connection
  con <- DBI::dbConnect(RSQLite::SQLite(), get_db_path())

  # create a SQL query to select project records
  str_query <- "SELECT * FROM projects WHERE (id = ? OR ? IS NULL);"

  # execute the query
  result <- DBI::dbGetQuery(
    conn = con,
    statement = str_query,
    params = list(.id_project, .id_project)
  )

  # disconnect
  DBI::dbDisconnect(con)

  # return the result
  return(tibble::as_tibble(result))
}

#' Get `timers` records for a calendar
#' 
#' @description
#' Returns a tibble of formatted data ready for use with the calendar display
#' 
#' @details
#' The `toastui::calendar()` works best with details in string format, so one 
#' of the tasks of this function is to loads timer and project details from 
#' the database and convert each variable to character(). Another task is to 
#' add the name of the project as the 'title' for the calendar entry, as this
#' is a required field by `toastui::calendar()`.
#' 
#' @seealso
#' [get_timer_records()] for the underlying function to query timers from the
#' the database.
#' 
#' [get_project_records()] for the underlying function to query projects from
#' the database.
#'
#' @param .id_date Numeric - an ID value that uniquely identifies a date, in the format 'YYYYMMDD', 
#' @param .id_week Numeric - an ID value that uniquely identifies a week, in the format 'YYYYWW'
#' 
#' @returns Tibble of `timers` records
#'
#' @export
#' @examples
#' # return all timer records
#' get_timer_records_for_calendar()
#' 
#' # return the timer records for this week
#' get_timer_records_for_calendar(.id_week = get_id_week(lubridate::now()))
#' 
#' # return the timer records for today
#' get_timer_records_for_calendar(.id_day = get_id_day(lubridate::now()))
get_timer_records_for_calendar <- function(
  .id_date = NA, 
  .id_week = NA
) {

  # get a list of projects
  df_projects <-
    get_project_records()
  
  # prepare the outcome object
  df_return <-
    # get the timer records as a tibble
    get_timer_records(.id_date = .id_date, .id_week = .id_week) |> 
    dplyr::mutate(
      # ensure datetimes are recognised
      start = start |> lubridate::as_datetime(),
      end = end |> lubridate::as_datetime()
    ) |> 
    # add in some project details
    dplyr::left_join(
      y = df_projects |> 
        dplyr::select('calendarId' = 'id', 'title' = 'name'),
      by = dplyr::join_by('calendarId' == 'calendarId')
    ) |> 
    # limit to required details
    dplyr::select(-c(id_date, id_week)) |> 
    # cast values to string (default accepted by toastui::calendar)
    dplyr::mutate(
      dplyr::across(
        dplyr::everything(),
        .fns = as.character
      )
    )
  
  # return the result
  return(df_return)

}

#' Get `projects` records for a calendar
#' 
#' @description
#' Returns a tibble of formatted data ready for use with the calendar display
#' 
#' @details
#' The `toastui::calendar()` works best with details in string format, so one 
#' of the tasks of this function is to loads project details from the database
#' and convert each variable to character(). Another task is to prepare the
#' colour scheme for display in `toastui::calendar()` by taking the hex colour
#' `colour` and using it to produce a colour scheme for `backgroundColor`,
#' a semi-transparent colour, `borderColor` a solid colour used  and `color`
#' used for the font.
#' 
#' @seealso
#' [get_project_records()] for the underlying function to query projects from
#' the database.
#'
#' @param .id_project Numeric - an ID value that uniquely identifies a project
#' 
#' @returns Tibble of `projects` records
#'
#' @export
#' @examples
#' # get all project records
#' get_project_records_for_calendar()
#' 
#' # get the record for a specific project id
#' get_project_records_for_calendar(.id_project = 1)
get_project_records_for_calendar <- function(
  .id_project = NA
) {

  # get a list of projects
  df_return <-
    get_project_records(.id_project = .id_project) |> 
    # set colors based on the associated colour
    dplyr::mutate(
      backgroundColor = colour |> grDevices::adjustcolor(alpha.f = 0.2),
      borderColor = colour,
      color = "black"
    ) |> 
    dplyr::select(-colour) |> # this field is not required
    # convert all details to strings (compatible with the toastui::calendar)
    dplyr::mutate(
      dplyr::across(
        dplyr::everything(),
        .fns = as.character
      )
    )
  
  # return the result
  return(df_return)

}