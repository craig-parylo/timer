
<!-- README.md is generated from README.Rmd. Please edit that file -->

# timer <img src="man/figures/logo.svg" align="right" height="139"/>

<!-- badges: start -->

<!-- badges: end -->

The goal of timer is to be a Shiny application to help you record time
spent on projects.

## Installation

You can install the development version of timer from
[GitHub](https://github.com/) with:

``` r
# install.packages("pak")
pak::pak("craig-parylo/timer")
```

## Features

This app is still under development and is not yet ready for regular
use. Available features include:

<figure>
<img src="dev/screenshots\v0.0.0.900\current_timer.png"
style="width:100.0%"
data-fig-alt="A {bslib} card showing options to select a project, start and stop the timer and a display of the time taken"
alt="Time your work" />
<figcaption aria-hidden="true">Time your work</figcaption>
</figure>

`{timer}` helps you track work time.

Select a project and click the Start button to begin timing. Click Stop
timer when you finish - the session will be saved to your activity.

<figure>
<img src="dev/screenshots\v0.0.0.900\calendar.png" style="width:100.0%"
data-fig-alt="A calendar view showing a week view, with time blocked out according to time recorded."
alt="See your weekly activity in a calendar format" />
<figcaption aria-hidden="true">See your weekly activity in a calendar
format</figcaption>
</figure>

See recorded timers in a calendar view that shows each timed session’s
duration and colour-codes sessions by project.

Use the navigation buttons to browse previous weeks or jump back to
today.

<figure>
<img src="dev/screenshots\v0.0.0.900\data.png" style="width:100.0%"
data-fig-alt="A table view of timer entries showing start and stop times along with ID values for the entry, the date, the week, the calendar (aka project), and the name of the project."
alt="See your raw data entries" />
<figcaption aria-hidden="true">See your raw data entries</figcaption>
</figure>

View your activity as a table of entries.

Use the sidebar control to switch the timeframe: Today, Yesterday, This
week, Last week or All time.

<figure>
<img src="dev/screenshots\v0.0.0.900\database.png" style="width:100.0%"
data-fig-alt="This app uses a SQLite database which is stored on your computer."
alt="You’re in control of your data with local SQL storage" />
<figcaption aria-hidden="true">You’re in control of your data with local
SQL storage</figcaption>
</figure>

Your data stays on your device. All information you enter is stored
locally in a SQLite database - nothing is shared.
