Go to the "Upload and test" tab of this app and upload CSV files.  Once uploaded a download button will appear above.

----

How to use the downloaded `.Rdata` file:

* Copy the below R code
* Paste the code into an R script
* Save the R script as a `.R` file in the same directory as downloaded `.Rdata` file
* Once the file is saved a "Run App" button with a green arrow should appear in Rstudio
* Press the Run App button
* Report errors to Adam Spannbauer ([aspannba@utk.edu](mailto:aspannba@utk.edu))

```r
# Update the below name to match your .Rdata file name
load("sql_simulator.Rdata")

# Run the below install line if you get any errors when loading libraries
# install.packages(c("shiny", "DT", "sqldf", "shinyAce"))

library(tools)
library(shiny)
library(DT)
library(sqldf)
library(shinyAce)

shinyAce:::initResourcePaths()
shiny::shinyApp(ui, server)
```

