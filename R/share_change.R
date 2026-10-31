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
#'   \item{result}{The result in words, written to follow the country name.}
#' }
#' @examples
#' changes <- share_change(electricity_mix, from = 2005, to = 2025)
#'
#' dplyr::filter(changes, country == "Australia", source == "coal")
#' # Coal's share of Australia's electricity fell by about 37 points
#'
#' dplyr::filter(changes, country == "Indonesia", source == "coal")
#' # Indonesia's data end in 2024, so its change cannot be measured
#' @importFrom dplyr case_when first group_by mutate select summarise
#' @export
share_change <- function(data, from, to) {
  if (to <= from) {
    stop("`to` must be later than `from`.", call. = FALSE)
  }
  data |>
    group_by(country, source) |>
    summarise(
      first_year = min(year),
      last_year = max(year),
      from_share = first(share[year == from]),
      to_share = first(share[year == to]),
      .groups = "drop"
    ) |>
    mutate(
      change = to_share - from_share,
      change_per_year = change / (to - from),
      result = case_when(
        first_year > from ~ paste0(
          "has no ", source, " data before ", first_year
        ),
        last_year < to ~ paste0(
          "has no ", source, " data after ", last_year
        ),
        is.na(from_share) ~ paste0("has no ", source, " data for ", from),
        is.na(to_share) ~ paste0("has no ", source, " data for ", to),
        from_share == 0 & to_share == 0 ~ paste0(
          "got none of its electricity from ", source, " in ", from,
          " or ", to
        ),
        round(change, 1) > 0 ~ paste0(
          "got ", round(to_share, 1), "% of its electricity from ", source,
          " in ", to, ", up from ", round(from_share, 1), "% in ", from
        ),
        round(change, 1) < 0 ~ paste0(
          "got ", round(to_share, 1), "% of its electricity from ", source,
          " in ", to, ", down from ", round(from_share, 1), "% in ", from
        ),
        TRUE ~ paste0(
          "got ", round(to_share, 1), "% of its electricity from ", source,
          " in ", to, ", about the same as in ", from
        )
      )
    ) |>
    select(
      country, source, from_share, to_share, change, change_per_year, result
    )
}
