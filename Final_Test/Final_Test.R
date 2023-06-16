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
library(gridExtra)
# ---------------------------------------------------------------------------------------------------------------------------------

dir <- dirname(rstudioapi::getActiveDocumentContext()$path)

# ---------------------------------------------------------------------------------------------------------------------------------

data <- read_csv(paste(dir, "/eat-R.csv", sep = ""))


ratioEat <- data %>%
  ggplot(aes(x=week, fill=iseat)) +
  geom_bar(position='stack')

groupData <- data %>% group_by(week) %>% count(type)

typeG <- groupData %>%
  ggplot(aes(x=week, y=n, fill=type))+
  geom_bar(stat='identity', position = 'dodge2')


grid.arrange(ratioEat, typeG, ncol=2)
