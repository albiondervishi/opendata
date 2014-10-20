# Script to create subset of the trafi data

library("dplyr")
library("lubridate")

# Note! This uses the earlier subset of the data

# Load raw data
trafi.raw <- read.csv("data.csv")
trafi.df <- tbl_df(trafi.raw)

library("gdata")
trafi.codes <- read.xls("14931-Koodisto.xlsx")

# Extract registering year
trafi.df$RegisteringYear <- year(ymd(trafi.df$ensirekisterointipvm))

# Focus on M1 cars only
trafi.subset.df <- trafi.df %>%
  filter(ajoneuvoluokka == "M1")

# Select wanted variables
trafi.subset.df <- trafi.subset.df %>%
  select(vari, omamassa, kayttovoima, merkkiSelvakielinen, kunta, Co2, RegisteringYear)
names(trafi.subset.df) <- c("Colour", "Weight", "EnergySource", "Manufacturer", "Location", "Co2", "RegisteringYear")

# Use ten latest complete years
trafi.subset.df <- trafi.subset.df %>%
  filter(RegisteringYear %in% 2004:2013)

# Use top 10 manufacturers, and 
man.table <- sort(table(trafi.subset.df$Manufacturer),decreasing = TRUE)
trafi.subset.df <- trafi.subset.df %>%
  filter(Manufacturer %in% names(man.table[1:25]))

# Use top 10 municipalities
mun.table <- sort(table(trafi.subset.df$Location),decreasing = TRUE)
trafi.subset.df <- trafi.subset.df %>%
  filter(Location %in% names(mun.table[1:30]))

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

write.csv(trafi.subset.df, file="trafi_subset2.csv")
