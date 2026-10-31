library(shiny)
library(bslib)
library(dplyr)
library(ggplot2)
library(powershift)

countries <- sort(unique(electricity_mix$country))
first_year <- min(electricity_mix$year)
latest_year <- max(electricity_mix$year)

sources <- c(
  "Coal" = "coal",
  "Gas" = "gas",
  "Oil" = "oil",
  "Nuclear" = "nuclear",
  "Hydro" = "hydro",
  "Wind" = "wind",
  "Solar" = "solar",
  "Bioenergy" = "bioenergy",
  "Other renewables" = "other renewables"
)

brand <- c(
  ink = "#222222",
  muted = "#B8B8B8",
  accent = "#006DAE"
)

focus_colours <- c("Context" = brand[["muted"]], "Focus" = brand[["accent"]])
line_colours <- c("Context" = "grey48", "Focus" = brand[["accent"]])

theme_cwd <- function(base_size = 16) {
  theme_minimal(base_size = base_size) +
    theme(
      plot.title.position = "plot",
      plot.caption.position = "plot",
      panel.grid.minor = element_blank(),
      panel.grid.major.y = element_blank(),
      axis.title = element_text(colour = brand[["ink"]]),
      axis.text = element_text(colour = brand[["ink"]]),
      plot.title = element_text(face = "bold", colour = brand[["ink"]]),
      plot.subtitle = element_text(colour = "grey35"),
      plot.caption = element_text(colour = "grey40", hjust = 0),
      legend.position = "bottom",
      plot.margin = margin(10, 36, 10, 10)
    )
}

with_sign <- function(change) {
  rounded <- round(change, 1)
  if_else(rounded > 0, paste0("+", rounded), paste0(rounded))
}

ui <- page_sidebar(
  title = "How quickly are countries changing their electricity?",
  theme = bs_theme(preset = "shiny", primary = "#006DAE"),
  fillable = FALSE,
  sidebar = sidebar(
    selectInput(
      "country",
      "Country to focus on",
      choices = countries,
      selected = "Australia"
    ),
    helpText("Drawn in blue and summarised in the boxes."),
    selectInput(
      "comparison",
      "Countries to compare with",
      choices = countries,
      selected = c(
        "United Kingdom", "Germany", "United States", "China", "India"
      ),
      multiple = TRUE
    ),
    helpText(
      "Drawn in grey. Click in the box and type a name to add a country.",
      "Click a name and press Delete to remove it."
    ),
    selectInput(
      "source",
      "Source of electricity",
      choices = sources,
      selected = "coal"
    ),
    helpText(
      "Coal, gas and oil are fossil fuels. Hydro, wind, solar, bioenergy",
      "and other renewables are renewable."
    ),
    sliderInput(
      "years",
      "Years to compare",
      min = first_year,
      max = latest_year,
      value = c(2005, latest_year),
      step = 1,
      sep = ""
    ),
    helpText(
      "Drag either end to change the start or end year.",
      "Fewer countries have data before 2000 or for 2025."
    )
  ),
  includeCSS("styles.css"),
  card(
    class = "question",
    p(
      strong("For: "),
      "an energy policy analyst preparing a briefing on a country's",
      "electricity transition."
    ),
    p(
      strong("Question: "),
      "how much has a country's electricity from one source changed between",
      "two years, and was that faster or slower than in other countries?"
    )
  ),
  layout_columns(
    value_box(
      title = "Focus country: share of electricity in the end year",
      value = textOutput("to_share")
    ),
    value_box(
      title = "Focus country: change between the two years",
      value = textOutput("change")
    ),
    value_box(
      title = "Countries shown with data for both years",
      value = textOutput("number_measured")
    )
  ),
  navset_card_tab(
    nav_panel(
      "Compare countries",
      h3(class = "headline", textOutput("headline", inline = TRUE)),
      textOutput("comparison_message"),
      plotOutput("share_plot", height = "480px"),
      p(
        "Each line is one country's share of electricity from the chosen",
        "source in each year. The dots mark the start and end years. The",
        "vertical gap between a country's two dots is its change in",
        "percentage points: a steeper line means faster change."
      ),
      markdown(
        "Data: [Our World in Data energy dataset](https://github.com/owid/energy-data), based on Ember and the Energy Institute's Statistical Review of World Energy, 1985 to 2025 (CC BY 4.0)."
      )
    ),
    nav_panel(
      "Whole mix",
      h3(class = "headline", textOutput("mix_headline", inline = TRUE)),
      plotOutput("mix_plot", height = "420px"),
      p(
        "Each bar is the change in one source's share of the focus country's",
        "electricity between the two years. The shares add up to 100% in each",
        "year, so the falls and rises roughly balance: the rising sources",
        "show what replaced the falling ones. The chosen source is blue."
      ),
      textOutput("mix_missing")
    ),
    nav_panel(
      "Table",
      p(
        "Every country shown, ordered from the largest fall to the largest",
        "rise. A dash means the year was not reported; the Result column says",
        "why."
      ),
      tableOutput("change_table")
    )
  )
)
