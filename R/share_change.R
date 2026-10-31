#' How much each source's share of electricity changed between two years
#'
#' For every country and source in `data`, finds the share of electricity
#' from that source in `from` and in `to`, the change in percentage points,
#' and the average change per year. A percentage point is the difference
#' between two percentages: a fall from 79% to 43% is a fall of 36 points.
#'
#' @param data A data frame with the same columns as [electricity_mix],
#'   usually `electricity_mix` itself.
#' @param from The start year.
#' @param to The end year. Must be later than `from`.
#' @return A data frame with one row per country and source, and columns:
#' \describe{
#'   \item{country}{Country name, or "World".}
#'   \item{source}{Source of electricity.}
#'   \item{from_share}{Percentage of electricity from the source in `from`.
#'     Missing if that year was not reported.}
#'   \item{to_share}{Percentage of electricity from the source in `to`.
#'     Missing if that year was not reported.}
#'   \item{change}{Change from `from` to `to`, in percentage points.
#'     Negative values are falls. Missing when either year is missing.}
#'   \item{change_per_year}{Average change per year, in percentage points.}
#' }
#' @importFrom dplyr first group_by mutate summarise
#' @export
share_change <- function(data, from, to) {
  data |>
    group_by(country, source) |>
    summarise(
      from_share = first(share[year == from]),
      to_share = first(share[year == to]),
      .groups = "drop"
    ) |>
    mutate(
      change = to_share - from_share,
      change_per_year = change / (to - from)
    )
}
