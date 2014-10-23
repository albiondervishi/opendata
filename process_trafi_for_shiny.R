# Script to create subset of the trafi data

library("dplyr")
library("lubridate")
library("gdata")


# Note! This uses the earlier subset of the data

# Load raw data
trafi.df <- tbl_df(read.csv("Avoindata_9.csv", fileEncoding="ISO-8859-1"))

trafi.codes <- read.xls("14931-Koodisto.xlsx")


# Focus on M1 cars only
trafi.subset.df <- filter(trafi.df, ajoneuvoluokka == "M1")

# Extract registering year, compute car age
trafi.subset.df$RegisteringYear <- year(ymd(trafi.subset.df$ensirekisterointipvm))
trafi.subset.df$CarAge <- 2014 - trafi.subset.df$RegisteringYear

# Select wanted variables
trafi.subset.df <- select(trafi.subset.df, merkkiSelvakielinen, mallimerkinta, RegisteringYear, kayttovoima, omamassa, vari, Co2, kunta, CarAge)
names(trafi.subset.df) <- c("Brand", "Model", "RegisteringYear", "EnergySource", "Weight", "Colour", "Co2", "Location", "CarAge")


# Use top Brands, and 
man.table <- sort(table(trafi.subset.df$Brand),decreasing = TRUE)
trafi.subset.df <- trafi.subset.df %>%
  filter(Brand %in% names(man.table[1:40]))
# 
# Use top 100 municipalities
mun.table <- sort(table(trafi.subset.df$Location),decreasing = TRUE)
trafi.subset.df <- trafi.subset.df %>%
  filter(Location %in% names(mun.table[1:100]))
# 
# Get most common force types
es.table <- sort(table(trafi.subset.df$EnergySource), decreasing = TRUE)
trafi.subset.df <- trafi.subset.df %>%
  filter(EnergySource %in% names(es.table[1:6]))

# Translate colour, energy type and location
energysource.codes <- droplevels(subset(trafi.codes, KOODISTONKUVAUS=="Polttoaine" & KIELI=="en"))
trafi.subset.df$EnergySource <- energysource.codes$LYHYTSELITE[match(as.vector(trafi.subset.df$EnergySource), as.vector(energysource.codes$KOODINTUNNUS))]

colour.codes <- droplevels(subset(trafi.codes, KOODISTONKUVAUS=="Ajoneuvon väri" & KIELI=="en"))
trafi.subset.df$Colour <- colour.codes$LYHYTSELITE[match(as.vector(trafi.subset.df$Colour), as.vector(colour.codes$KOODINTUNNUS))]

location.codes <- droplevels(subset(trafi.codes, KOODISTONKUVAUS=="Kuntien numerot ja nimet" & KIELI=="fi"))
# energysource.codes$KOODINTUNNUS <- as.numeric(as.character(energysource.codes$KOODINTUNNUS))
trafi.subset.df$Location <- location.codes$PITKASELITE[match(as.vector(trafi.subset.df$Location), as.numeric(as.vector(location.codes$KOODINTUNNUS)))]

# omit NA
trafi.subset.df <- droplevels(na.omit(trafi.subset.df))

# Save
save(trafi.subset.df, file="trafi-shiny/Trafi_subset1.RData")

# # Split to test and training set
# set.size <- 100000
# trafi.train.df <- droplevels(trafi.subset.df[1:set.size, ])
# trafi.test.df <- droplevels(trafi.subset.df[1:set.size + set.size, ])
# # Check that level sets match
# 
# save(trafi.train.df, trafi.test.df, file="trafi-shiny/Trafi_subset1_train+test.RData")





# ## TEST PREDICTION #######
# 
# load("trafi-shiny/Trafi_subset1.RData")
# 
# 
# 
# input <- list(variables=c("Weight", "Brand"))
# # pred.formula <- as.formula(paste("Co2 ~ ", paste(input$variables, collapse=" + ")))
# # res <- lm(formula=pred.formula, family="gaussian", data=trafi.subset.df)
# 
# # With h2o
# install.packages("h2o-2.8.0.1/R/h2o_2.8.0.1.tar.gz")
# library("h2o")
# H2Olocal <- h2o.init()
# trafi.h2o <- as.h2o(H2Olocal, trafi.subset.df)
# trafi.glm <- h2o.glm(y="Co2", x=input$variables, data=trafi.h2o, family="gaussian", alpha=0.5,
#                      variable_importances=TRUE, use_all_factor_levels=TRUE, standardize=FALSE)
# # coefs <- trafi.glm@model$coefficients
# # coefs.manufactures <- sort(coefs[grep("Brand", names(coefs))], decreasing = TRUE)



# library("glmnet")
# res <- lm(x=as.matrix(trafi.subset.df[, input$variables]), y=trafi.subset.df$Co2, family="gaussian")

## COMPUTE AGGREGATES OVER YEAR #######

# # variables: weight, location, Brand, colour, co2
# # values: number of, weight, Co2
# trafi.averages.df <- trafi.subset.df %>%
#   group_by(Colour, Weight, EnergySource, Brand, Location, Co2) %>%
#   summarise(ColourAvg = mean())
