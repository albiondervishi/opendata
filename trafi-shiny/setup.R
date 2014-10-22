library("shiny")

# Init h2o
library("h2o")
H2Olocal <- h2o.init()

# # Load data and setup with h2o
# load("trafi-shiny/Trafi_subset1.RData")
# 
# # Sample training and test sets
# train.size <- 2/3
# train.inds <- sample(nrow(trafi.subset.df), ceiling(train.size*nrow(trafi.subset.df)))
# trafi.train.df <- droplevels(trafi.subset.df[train.inds, ])
# trafi.test.df <- droplevels(trafi.subset.df[-train.inds, ])
# 
# # Check that level sets match
# for (i in c(1, 4, 6, 8))
#   stopifnot(all(levels(trafi.train.df[[i]])==levels(trafi.test.df[[i]])))
# save(trafi.train.df, trafi.test.df, file="trafi-shiny/Trafi_subset2_train+test.RData")
load("trafi-shiny/Trafi_subset2_train+test.RData")

# Filter out small groups
trafi.train.df <- droplevels(subset(trafi.train.df, !(EnergySource %in% c("Electricity", "Petrol/CNG", "Petrol/Electricity")) & Colour != "Multi-coloured"))
trafi.test.df <- droplevels(subset(trafi.test.df, !(EnergySource %in% c("Electricity", "Petrol/CNG", "Petrol/Electricity")) & Colour != "Multi-coloured"))

# Transform to h2o objects
trafi.train.h2o <- as.h2o(H2Olocal, trafi.train.df)
trafi.test.h2o <- as.h2o(H2Olocal, trafi.test.df)


# OLD STUFF


# trafi.subset.df <- head(trafi.subset.df, 100000)
# trafi.h2o <- as.h2o(H2Olocal, trafi.subset.df)

# Split to test and training set
# load("trafi-shiny/Trafi_subset1_train+test.RData")
# set.size <- 100000
# trafi.train.df <- droplevels(trafi.subset.df[1:set.size, ])
# trafi.test.df <- droplevels(trafi.subset.df[1:set.size + set.size, ])


