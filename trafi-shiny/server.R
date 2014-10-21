library("h2o")
library(googleVis)
library(reshape2)
library(ggplot2)
theme_set(theme_grey(20))
library(gridExtra)

# Init h2o
H2Olocal <- h2o.init()

# Load data and setup with h2o
# load("Trafi_subset1.RData")
# trafi.subset.df <- head(trafi.subset.df, 100000)
# trafi.h2o <- as.h2o(H2Olocal, trafi.subset.df)


# Split to training and test set
load("Trafi_subset1_train+test.RData")
trafi.train.h2o <- as.h2o(H2Olocal, trafi.train.df)
trafi.test.h2o <- as.h2o(H2Olocal, trafi.test.df)


shinyServer(function (input, output) {
  
  ## DATA TABLE #######
  
  output$gvistable <- renderGvis({
    
    return(gvisTable(head(trafi.train.df, 200), options=list(page='enable', pageSize=20)))
  })
  
  
  ## REGRESSION ######
  
  glm_res <- reactive({
    message("Running regression with", input$variables)
    # Run regression
    glm.res <- h2o.glm(y="Co2", x=input$variables, data=trafi.train.h2o, family="gaussian", alpha=0.5,
                         variable_importances=TRUE, use_all_factor_levels=TRUE, standardize=FALSE)
    return(glm.res)
  })
  
  get_coefs <- reactive({    
    message("Processing regression coefficients")
    glm.res <- glm_res()
    coefs.all <- glm.res@model$coefficients
    # Process categorical variables
    cat.vars <- intersect(input$variables, c("Colour", "EnergySource", "Manufacturer", "Location"))
#     if (length(cat.vars)==0)
#       return(NULL) # stop("Choose at least one categorical variable")
    names(cat.vars) <- cat.vars
    coefs.list <- lapply(cat.vars, function(x) sort(coefs.all[grep(x, names(coefs.all))], decreasing = TRUE))
    coefs.list <- lapply(coefs.list, function(x) {res=x; names(res)=sapply(strsplit(names(res), split="\\."), "[", 2); res} )
    # Process numeric variables
    coefs.dfs <- lapply(coefs.list, function(x) data.frame(Category=factor(names(x), levels=names(x)), Coefficient=x))
    # Add one data frame for numeric variables
    coefs.others <- coefs.all[setdiff(names(coefs.all), names(unlist(coefs.list)))]    
    
    
 #   coefs.dfs <- c(list(Numeric=data.frame(Category=names(coefs.others), Coefficient=coefs.others)), coefs.dfs)
    return(list(categorical=coefs.dfs, others=coefs.others))
  })

  ## PREDICTIVE PERFORMANCE ######

  get_prediction_results <- reactive({
    message("Predicting results for training and test data")
    glm.res <- glm_res()
    train.fit <- h2o.predict(object=glm.res, newdata=trafi.train.h2o)
    test.fit <- h2o.predict(object=glm.res, newdata=trafi.test.h2o)
    return(list(train=train.fit, test=test.fit))
  })

  output$pred_ggplot <- renderPlot({
    # Plotting prediction results
    pred.fits <- get_prediction_results()
    train.res.df <- data.frame(Co2.true = trafi.train.df$Co2, Co2.pred = as.data.frame(pred.fits$train)$predict)
    test.res.df <- data.frame(Co2.true = trafi.test.df$Co2, Co2.pred = as.data.frame(pred.fits$test)$predict)
    train.rmse <- sqrt( sum( (train.res.df$Co2.true - train.res.df$Co2.pred)^2 , na.rm = TRUE ) / nrow(train.res.df) )
    test.rmse <- sqrt( sum( (test.res.df$Co2.true - test.res.df$Co2.pred)^2 , na.rm = TRUE ) / nrow(test.res.df) )
    
    xlims <- c(min(train.res.df$Co2.true, test.res.df$Co2.true), max(train.res.df$Co2.true, test.res.df$Co2.true))
    ylims <- c(min(train.res.df$Co2.pred, test.res.df$Co2.pred), max(train.res.df$Co2.pred, test.res.df$Co2.pred))
    
    p.train <- ggplot(train.res.df, aes(x=Co2.true, y=Co2.pred)) + geom_point(alpha=0.5) + 
      ggtitle(paste("Training data, RMSE:", round(train.rmse, d=1))) + 
      labs(x="True Co2", y="Predicted Co2") + 
      xlim(xlims[1], xlims[2]) + ylim(ylims[1], ylims[2]) + abline(a=0, b=1)
    p.test <- ggplot(test.res.df, aes(x=Co2.true, y=Co2.pred)) + geom_point(alpha=0.5) + 
      ggtitle(paste("Test data, RMSE:", round(test.rmse, d=1))) + 
      labs(x="True Co2", y="Predicted Co2") + 
      xlim(xlims[1], xlims[2]) + ylim(ylims[1], ylims[2]) + abline(a=0, b=1)
    print(arrangeGrob(p.train, p.test, nrow=1))
  })

  ## REGRESSION COEFFICIENTS #######

  output$coefs_table <- renderGvis({
    coefs <- get_coefs()
    coefs.others <- coefs$others
#     if (length(coefs.others)==0)
#       return(NULL)
    df <- data.frame(Variable=names(coefs.others), Coefficient=coefs.others)
    coefs.table <- gvisTable(df, options=list(width='300px'))
    return(coefs.table)
  })
 
  output$coefs_ggplot <- renderPlot({    
    coefs <- get_coefs()
    coefs.dfs <- coefs$categorical
#     if (is.null(coefs.dfs))
#       return(NULL)
    plots <- list()
    for (i in 1:length(coefs.dfs)) {
      plots[[i]] <- ggplot(coefs.dfs[[i]], aes(x=Category, y=Coefficient)) + geom_bar(stat="identity") + coord_flip() + 
        labs(y="CO2 coefficient (g/km)", x=names(coefs.dfs)[i])
    }
    # Compute length of results
    res.len <- sapply(coefs.dfs, nrow)
    p.coefs <- do.call(arrangeGrob, c(plots, list(ncol=1, heights=res.len/sum(res.len))))
    print(p.coefs)
 })
 
 output$coefs_plot_ui <- renderUI({
   coefs <- get_coefs()
   coefs.dfs <- coefs$categorical
#    if (is.null(coefs.dfs))
#      return(NULL)
   h <- max(250, 16*sum(sapply(coefs.dfs, nrow)))
   plotOutput("coefs_ggplot", height=paste0(h,"px"), width="60%")
 })
 
})