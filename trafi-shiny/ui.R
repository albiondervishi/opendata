shinyUI(fluidPage(
  
  # Include googel analytics script (updated 8.10.2014)
  #   tags$head(includeScript("google-analytics.js")),
  
  # Application title
  titlePanel("Trafi open data"),
  
  sidebarLayout(
    sidebarPanel(
      # Adjust size
      tags$head(
        tags$style(type="text/css", "select { width: 200px; }"),
        tags$style(type="text/css", "textarea { max-width: 180px; }"),
        tags$style(type="text/css", ".jslider { max-width: 200; }"),
        tags$style(type='text/css', ".well { max-width: 200px; }"),
        tags$style(type='text/css', ".span4 { max-width: 200px; }")
      ),
      p("Here you can explore and visualize open car registry data by Trafi"),
      p(a("Data source", href="http://www.trafi.fi/tietopalvelut/avoin_data")),
      p("Note that loading the data takes a few seconds")
      
      #      selectInput("plotType", "Visualisointitapa", c("Motion chart" = "motionchart", "Kartta" = "map")),
      #       conditionalPanel(
      #         condition = "input.plotType == 'motionchart'",
      #         helpText(h4("Motion chartin asetukset:")),
      #         
      #         radioButtons("region.category", "Aluekategoria",
      #                      c("Kunta" = "kunta",
      #                        "Maakunta" = "maakunta",
      #                        "Seutukunta" = "seutukunta")),
      # br()
      #       p("Made by", a("@ouzor", href="https://twitter.com/ouzor")),
      #       helpText(a("Datalähde: Sotkanet", href="http://www.sotkanet.fi", target="_blank")),
      #       helpText(a("Lähdekoodi GitHubissa", href="https://github.com/ouzor/sotkanet-shiny", target="_blank"))
    ),
    
    mainPanel(
      tabsetPanel(
        tabPanel("Data overview",
                 h4("Here's a sample of the data"),
                 htmlOutput("gvistable")
        ),
        tabPanel("Prediction",
                 h3("Predict CO2 emissions of cars"),
                 checkboxGroupInput("variables","Select variables to use for prediction",
                                    choices=c("Weight"="Weight",
                                              "CarAge" = "CarAge",
                                              "Colour"="Colour",
                                              "EnergySource"="EnergySource",
                                              "Manufacturer"="Manufacturer",
                                              "Location"="Location"),
                                    selected=c("Weight", "CarAge", "Colour")
                 ),
                 submitButton("Run regression"),
                 #                 plotOutput("coefs_ggplot", height="400px", width="80%"),
                 h3("Regression results"),
                 h4("Predictive performance"),
                 plotOutput("pred_ggplot", height="400px", width="800px"),
                 
                 h4("Regression coefficients for numerical variables"),
                 htmlOutput("coefs_table"),
                 h4("Regression coefficients for categorical variables"),
                 uiOutput("coefs_plot_ui")
        )
      )
    )
  )
))