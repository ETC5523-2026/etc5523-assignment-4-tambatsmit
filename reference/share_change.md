# How much each source's share of electricity changed between two years

For every country and source in `data`, finds the share of electricity
from that source in `from` and in `to`, the change in percentage points,
and the average change per year. A percentage point is the difference
between two percentages: a fall from 79% to 43% is a fall of 36 points.

## Usage

``` r
share_change(data, from, to)
```

## Arguments

- data:

  A data frame with the same columns as
  [electricity_mix](https://etc5523-2026.github.io/etc5523-assignment-4-tambatsmit/reference/electricity_mix.md),
  usually `electricity_mix` itself.

- from:

  The start year.

- to:

  The end year. Must be later than `from`.

## Value

A data frame with one row per country and source, and columns:

- country:

  Country name, or "World".

- source:

  Source of electricity.

- from_share:

  Percentage of electricity from the source in `from`. Missing if that
  year was not reported.

- to_share:

  Percentage of electricity from the source in `to`. Missing if that
  year was not reported.

- change:

  Change from `from` to `to`, in percentage points. Negative values are
  falls. Missing when either year is missing.

- change_per_year:

  Average change per year, in percentage points.

- result:

  The result in words, written to follow the country name.

## Examples

``` r
changes <- share_change(electricity_mix, from = 2005, to = 2025)

dplyr::filter(changes, country == "Australia", source == "coal")
#> # A tibble: 1 × 7
#>   country   source from_share to_share change change_per_year result            
#>   <chr>     <fct>       <dbl>    <dbl>  <dbl>           <dbl> <chr>             
#> 1 Australia coal         79.3     42.7  -36.6           -1.83 got 42.7% of its …
# Coal's share of Australia's electricity fell by about 37 points

dplyr::filter(changes, country == "Indonesia", source == "coal")
#> # A tibble: 1 × 7
#>   country   source from_share to_share change change_per_year result            
#>   <chr>     <fct>       <dbl>    <dbl>  <dbl>           <dbl> <chr>             
#> 1 Indonesia coal         39.0       NA     NA              NA has no coal data …
# Indonesia's data end in 2024, so its change cannot be measured
```
