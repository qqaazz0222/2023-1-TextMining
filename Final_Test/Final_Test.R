# ---------------------------------------------------------------------------------------------------------------------------------
# 라이브러리 설치
# install.packages('rstudioapi')
# install.packages('dplyr')
# install.packages("gridExtra")
# 라이브러리 부착
library(rstudioapi)
library(dplyr)
library(readr)
library(ggplot2)
# ---------------------------------------------------------------------------------------------------------------------------------

dir <- dirname(rstudioapi::getActiveDocumentContext()$path)

# ---------------------------------------------------------------------------------------------------------------------------------

data <- read_csv(paste(dir, "/ainews.csv", sep = ""))
