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

# 데이터 불러오기
data <- read_csv(paste(dir, "/ainews.csv", sep = ""))

# 텍스트 전처리
preData <- data %>% str_replace_all("")
