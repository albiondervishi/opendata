shinyUI(fluidPage(
  
  # Include googel analytics script
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
#      p("Note that loading the data takes a few seconds!")
      h4("TODO"),
      p("- RMSE strangely similar between training and test data - double check code!"),
      p("- Include more variables to the data and prediction"),
      p("- Regression stuff takes a long time now, should be faster. Maybe remove training data prediction computation and plot, should make it faster."),
      p("- Now we filter with ajoneuvoluokka==M1, but that may still include things like asuntovaunu, which does not make sense. So we should check the korityyppi included in M1 and filter more based on that. It should make the regression more sensible and better.")
    ),
    
    mainPanel(
      tabsetPanel(
        tabPanel("Data overview",
                 h4("Here's a sample of the data"),
                 p("In total the data has about 1.5 million rows"),
                 htmlOutput("gvistable")
        ),
        tabPanel("Prediction",
                 h3("Predict CO2 emissions of cars"),
#                 radioButtons("include.electric", "Include electric cars?", c("Yes"=TRUE, "No"=FALSE), selected="Yes"),
                 checkboxGroupInput("variables","Select variables to use for prediction",
                                    choices=c("Weight"="Weight",
                                              "CarAge" = "CarAge",
                                              "Colour"="Colour",
                                              "EnergySource"="EnergySource",
                                              "Brand"="Brand",
                                              "Location"="Location"),
                                    selected=c("Weight", "CarAge", "Colour")
                 ),
                 submitButton("Run regression"),
                 #                 plotOutput("coefs_ggplot", height="400px", width="80%"),
                 h3("Regression results"),
                 h4("Predictive performance"),
                 sliderInput("plot.size", "Set amount of data to plot (bigger takes longer!)", min=0.05, max=0.5, value=0.05),
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
