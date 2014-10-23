### Some instructions for running the trafi-shiny

1. Download data from [Trafi](http://www.trafi.fi/tietopalvelut/avoin_data) unzip to the opendata-folder
2. Run R script `process_trafi_for_shiny.R` (needs to be run only once on your machine, unless you want to change the preprocessing, e.g. include more variables)
3. Download and unzip [latest H2O](http://0xdata.com/download/)
4. Install H2O R package with `install.packages("h2o-2.8.0.1/R/h2o_2.8.0.1.tar.gz", repos=NULL, type="source")`. Note! Has some dependencies! No need to install H2O separately.
5. Run `setup.R` to setup H2O (takes a bit of time, as it will start H2O in the background). This is done separately from shiny to reduce shiny loading time.
6. Install packages listed in the beginning of `server.R`
7. Deploy shiny app locally with `runApp("trafi-shiny", launch.browser = TRUE)`

Note that this shiny app can not be deployed in shinyapps.io, as it can only load packages from CRAN or Github (h2o R package is in Github, that could be tried...)