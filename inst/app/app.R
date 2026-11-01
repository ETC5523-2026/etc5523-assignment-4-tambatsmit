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

server <- function(input, output, session) {
  changes <- reactive({
    validate(need(
      input$years[1] < input$years[2],
      "Choose two different years with the slider."
    ))

    share_change(electricity_mix, from = input$years[1], to = input$years[2])
  }, label = "changes")

  source_changes <- reactive({
    validate(need(
      input$country != "",
      "Choose a country to focus on in the sidebar."
    ))

    changes() |>
      filter(
        source == input$source,
        country %in% c(input$country, input$comparison)
      )
  }, label = "source_changes")

  focus_change <- reactive({
    focus <- source_changes() |>
      filter(country == input$country)

    validate(need(nrow(focus) > 0, "No data"))
    focus
  }, label = "focus_change")

  output$to_share <- renderText({
    if (is.na(focus_change()$to_share)) {
      return("No data")
    }

    paste0(round(focus_change()$to_share, 1), "%")
  })

  output$change <- renderText({
    if (is.na(focus_change()$change)) {
      return("Not measurable")
    }

    paste(with_sign(focus_change()$change), "points")
  })

  output$number_measured <- renderText({
    paste(
      sum(!is.na(source_changes()$change)),
      "of",
      length(unique(c(input$country, input$comparison)))
    )
  })

output$headline <- renderText({
  validate(need(
    input$country %in% source_changes()$country,
    paste0(
      input$country, " has no ", input$source, " data. ",
      "Choose another source or country."
    )
  ))

  if (is.na(focus_change()$change)) {
    return(paste0(
      input$country, " ", focus_change()$result, ". ",
      "Move the slider to years with data."
    ))
  }

  paste0(input$country, " ", focus_change()$result, ".")
})

output$comparison_message <- renderText({
  if (length(input$comparison) == 0) {
    return(
      "Add countries to compare with in the sidebar to see whether this change is fast or slow."
    )
  }

  measured <- source_changes() |>
    filter(!is.na(change)) |>
    arrange(change)

  if (nrow(measured) == 0) {
    return(
      "None of the countries shown has data for both years. Choose other years or countries."
    )
  }

  if (nrow(measured) == 1) {
    return(paste0(
      "Of the countries shown, only ", measured$country, " has data for ",
      "both years. The Table tab explains the others."
    ))
  }

  paste0(
    "Of the countries shown, the change ranged from ",
    with_sign(measured$change[1]), " points in ",
    measured$country[1], " to ",
    with_sign(measured$change[nrow(measured)]), " points in ",
    measured$country[nrow(measured)], ". The Table tab lists every country."
  )
})

selected_data <- reactive({
  validate(need(
    input$years[1] < input$years[2],
    "Choose two different years with the slider."
  ))

  electricity_mix |>
    filter(
      source == input$source,
      country %in% c(input$country, input$comparison),
      between(year, input$years[1], input$years[2])
    )
}, label = "selected_data")

output$share_plot <- renderPlot({
  validate(need(
    nrow(selected_data()) > 0,
    "None of the countries shown has data for these years."
  ))

  plot_data <- selected_data() |>
    mutate(focus = if_else(country == input$country, "Focus", "Context"))

  endpoints <- plot_data |>
    group_by(country) |>
    slice_max(year, n = 1, with_ties = FALSE) |>
    ungroup()

  ends <- plot_data |>
    filter(year %in% input$years)

  year_step <- if_else(input$years[2] - input$years[1] < 10, 1, 5)

  ggplot(plot_data, aes(year, share, group = country)) +
    geom_line(colour = brand[["muted"]], linewidth = 0.75) +
    geom_line(
      data = filter(plot_data, focus == "Focus"),
      colour = brand[["accent"]],
      linewidth = 1.5
    ) +
    geom_point(data = ends, aes(colour = focus), size = 3) +
    ggrepel::geom_text_repel(
      data = endpoints,
      aes(label = country, colour = focus),
      direction = "y",
      hjust = 0,
      nudge_x = 0.02 * (input$years[2] - input$years[1]),
      segment.colour = NA,
      seed = 5523,
      size = 4.5
    ) +
    scale_colour_manual(values = line_colours, guide = "none") +
    scale_x_continuous(
      breaks = scales::breaks_width(year_step),
      expand = expansion(mult = c(0.01, 0.2))
    ) +
    scale_y_continuous(labels = scales::label_percent(scale = 1)) +
    coord_cartesian(clip = "off") +
    labs(x = NULL, y = paste("Share of electricity from", input$source)) +
    theme_cwd()
})

mix_changes <- reactive({
  validate(need(
    input$country != "",
    "Choose a country to focus on in the sidebar."
  ))

  mix <- changes() |>
    filter(country == input$country, !is.na(change)) |>
    arrange(change)

  validate(need(
    nrow(mix) > 0,
    paste(input$country, "has no sources with data for both years.")
  ))

  mix |>
    mutate(
      source = factor(source, levels = source),
      focus = if_else(source == input$source, "Focus", "Context")
    )
}, label = "mix_changes")

output$mix_headline <- renderText({
  paste0(
    "In ", input$country, " from ", input$years[1], " to ", input$years[2],
    ", the change ranged from ",
    with_sign(mix_changes()$change[1]), " points for ",
    mix_changes()$source[1], " to ",
    with_sign(mix_changes()$change[nrow(mix_changes())]),
    " points for ", mix_changes()$source[nrow(mix_changes())], "."
  )
})

output$mix_plot <- renderPlot({
  ggplot(mix_changes(), aes(change, source, fill = focus)) +
    geom_col(width = 0.72) +
    geom_vline(xintercept = 0, colour = brand[["ink"]]) +
    geom_text(
      aes(
        label = with_sign(change),
        hjust = if_else(change < 0, 1.15, -0.15)
      ),
      colour = brand[["ink"]],
      size = 4.5
    ) +
    scale_fill_manual(values = focus_colours, guide = "none") +
    scale_x_continuous(expand = expansion(mult = 0.15)) +
    coord_cartesian(clip = "off") +
    labs(
      x = paste(
        "Change in share of electricity,", input$years[1], "to",
        input$years[2], "(percentage points)"
      ),
      y = NULL
    ) +
    theme_cwd()
})

output$mix_missing <- renderText({
  missing <- changes() |>
    filter(country == input$country, is.na(change))

  if (nrow(missing) == 0) {
    return("")
  }

  paste0(
    "Not shown, because one of the years was not reported: ",
    paste(missing$source, collapse = ", "), "."
  )
})

output$change_table <- renderTable({
  change_table <- source_changes() |>
    arrange(change, country) |>
    transmute(
      Country = country,
      from_share = round(from_share, 1),
      to_share = round(to_share, 1),
      `Change (points)` = round(change, 1),
      `Change per year (points)` = round(change_per_year, 1),
      Result = result
    )

  names(change_table)[2:3] <- paste0("Share in ", input$years, " (%)")
  change_table
}, striped = TRUE, bordered = TRUE, spacing = "m", digits = 1, na = "-")
}

shinyApp(ui, server)



