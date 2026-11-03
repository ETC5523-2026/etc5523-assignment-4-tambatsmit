
<!-- README.md is generated from README.Rmd. Please edit that file -->

# powershift

powershift helps an **energy policy analyst preparing a briefing on a
country’s electricity transition** answer one question:

> How much has the share of a country’s electricity from one source
> changed between two years, and was that faster or slower than in other
> countries?

Countries are moving their electricity away from coal and towards wind
and solar at very different speeds. Comparing the change in each
source’s share of electricity shows which countries are moving fastest,
and which sources are replacing which.

The package contains:

- `electricity_mix`: Our World in Data estimates of how much of every
  country’s electricity came from nine sources, from 1985 to 2025.
- `share_change()`: How much each source’s share changed between two
  years, in percentage points, with the result in words.
- `run_app()`: A Shiny app that compares countries using these.

Documentation website:
<https://etc5523-2026.github.io/etc5523-assignment-4-tambatsmit/>

## Installation

Install the package from GitHub:

``` r
# install.packages("remotes")
remotes::install_github("ETC5523-2026/etc5523-assignment-4-tambatsmit")
```

## Launch the app

``` r
library(powershift)
run_app()
```

Choose a country to focus on, the countries to compare it with, a source
of electricity and two years. The app reports how much that source’s
share changed in each country, draws each country’s share over time,
shows which sources rose and fell in the focus country, and explains any
country without data for a year. The **Guide** tab explains every
control and field.

## Example

How much did coal’s share of electricity change from 2005 to 2025 in
Australia, the United Kingdom, China and India?

``` r
library(powershift)

share_change(electricity_mix, from = 2005, to = 2025) |>
  dplyr::filter(
    source == "coal",
    country %in% c("Australia", "United Kingdom", "China", "India")
  ) |>
  dplyr::select(country, from_share, to_share, change)
#> # A tibble: 4 × 4
#>   country        from_share to_share change
#>   <chr>               <dbl>    <dbl>  <dbl>
#> 1 Australia            79.3   42.7   -36.6 
#> 2 China                79.2   54.3   -24.9 
#> 3 India                67.9   70.8     2.90
#> 4 United Kingdom       33.8    0.113 -33.7
```

Coal’s share of Australia’s electricity fell by about 37 percentage
points, the largest fall of these four countries. The United Kingdom
started lower and has almost stopped using coal, while India’s share
rose slightly. The `result` column, not shown here, explains each case
in words.

## Data

- **Source:** The [Our World in Data energy
  dataset](https://github.com/owid/energy-data), based on Ember’s Yearly
  Electricity Data and the Energy Institute’s Statistical Review of
  World Energy.
- **Preparation:** `data-raw/electricity_mix.R` reads
  `data-raw/owid-energy-data.csv` (downloaded on 30 October 2026),
  removes regional and income-group totals, and reshapes the share and
  generation columns for nine sources into one row per country, year and
  source. Run it from the package folder to rebuild
  `data/electricity_mix.rda`.
- **Licence:** The data are available under the [CC BY
  4.0](https://creativecommons.org/licenses/by/4.0/) licence. Cite them
  as “Our World in Data, based on Ember (2026) and the Energy Institute
  Statistical Review of World Energy (2025)”.

## Licence

The package code is released under the MIT licence.

## Generative AI declaration

**Generative AI declaration:** I used Claude (Anthropic) to suggest the
dataset and the app’s intended user and question; write and debug code
for data preparation, package functions, the Shiny app and pkgdown
setup; style and format the app and project materials; draft and rewrite
wording for the README, vignette and documentation; proofread the app
and documentation; suggest commit messages; and plan the walkthrough. I
used ChatGPT (OpenAI) to review the package against the marking
criteria. I ran and tested the code, checked the figures against the
data, revised the text, and take responsibility for all submitted work.
