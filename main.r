# Mac users: Install the GNU Fortran (gfortran-4.2.3.dmg) library from the CRAN toolsdirectory:http://cran.r-project.org/bin/macosx/tools.3.
# Install JAGS version 3.4.0 from Martyn Plummer’s repository:http://cran.r-project.org/bin/macosx/tools
# Install JAGS version 3.4.0 from Martyn Plummer’s repository:http://sourceforge.net/projects/mcmc-jags/files/JAGS/3.x/
# install.packages("R2jags",dependencies=TRUE,repos="http://cran.us.r-project.org")
# install.packages("runjags",dependencies=TRUE,repos="http://cran.us.r-project.org")
# install.packages("MCMCpack",dependencies=TRUE,repos="http://cran.us.r-project.org")
# install.packages("fitdistrplus", dependencies=TRUE,repos="http://cran.us.r-project.org")

library("R2jags")
library("readxl")
library("fitdistrplus")
library("tidyverse")

set.seed(42)

setwd("/Users/marcelbraasch/RProjects/stochastic_processes/")
data <- read_excel("data.xlsx")
data <- select(data, -1)  # Drop first

# Create the cumulative data for all five series
N <- nrow(data)
M <- ncol(data)
names <- colnames(data)
SPI_counted <- tibble(a = 1:N)
for (j in 1:M) {
  d <- data[[j]]
  name <- names[j]
  counter <- 0
  cumulative <- c()
  for (i in 1:N) {
    if (d[i] <= -1) { counter <- counter + 1}
    cumulative <- c(cumulative, counter)
  }
  SPI_counted$x <- cumulative
  names(SPI_counted)[ncol(SPI_counted)] <- names[j]  # Rename
}

# Plottinng the count SPI graphs
plot(stepfun(1:(length(SPI_counted$`1 mês`)-1), SPI_counted$`1 mês`), cex.points = 0.1, lwd=0, main="Count SPI for 1 month")
plot(stepfun(1:(length(SPI_counted$`3 meses`)-1), SPI_counted$`3 meses`), cex.points = 0.1, lwd=0, main="Count SPI for 3 months")
plot(stepfun(1:(length(SPI_counted$`6 meses`)-1), SPI_counted$`6 meses`), cex.points = 0.1, lwd=0, main="Count SPI for 6 months")
plot(stepfun(1:(length(SPI_counted$`12 meses`)-1), SPI_counted$`12 meses`), cex.points = 0.1, lwd=0, main="Count SPI for 12 months")



# Provide the data (for `1 mês` series)
y <- SPI_counted$`1 mês`
N <- nrow(data)
plp.mod.data <- list("y", "N")

# Parameters to be estimated
plp.mod.params <- c("alpha1", "sigma1")

# Define starting values
plp.mod.inits <- function(){
  list("alpha1" = runif(1, min=0, max=100), "sigma1" = runif(1, min=0, max=100))
}

# Define model
plp.mod <- function() {
  # Likelihood
  for (i in 1:N) {
    y[i] <- (alpha1/sigma1) * ((i/sigma1)**(alpha1-1)) * exp(-(N/sigma1)**alpha1)#+0.00000001)
  }
  # Prior
  alpha1 ~ dunif(0, 100)
  sigma1 ~ dunif(0, 100)
}

# Fit model
plp.mod.fit <- jags(data = plp.mod.data, 
                    #inits = plp.mod.inits,
                    parameters.to.save = plp.mod.params,
                    n.chains = 3, n.iter = 15000,
                    n.burnin = 10000, model.file = plp.mod)
plot(plp.mod.fit)
print(plp.mod.fit)

alpha1 <- 2
sigma1 <- 10
for (i in 1:N) {
  print((alpha1/sigma1) * ((i/sigma1)**(alpha1-1)))
  print(exp(-(N/sigma1)**alpha1))
  print(" ")
  }
