library(tidyverse)
library(ggmap)
library(readr)
library(dplyr)

J <- read.csv("csv/sm_j79.csv")

class(J)
dim(J)
names(J)


# Find if there NAs in the df
is.na(J)
any(is.na(J))
#Total number of NAs in the df
sum(is.na(J))

#find rows with no missing values
complete.cases(J)

na.omit(J)

head(J)

# omit the NAs in the df
J <- na.omit(J)
#Total number of NAs in the df
sum(is.na(J))



J  %>% count(X1979.01.01)
