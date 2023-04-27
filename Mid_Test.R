# ---------------------------------------------------------------------------------------------------------------------------------
# 라이브러리 설치
install.packages('rstudioapi')
install.packages('dplyr')
install.packages('tidytext')
install.packages('readr')
# 라이브러리 부착
library(rstudioapi)
library(dplyr)
library(stringr)
library(tidytext)
library(KoNLP)
library(ggplot2)
library(showtext)
library(tidyr)
library(readr)
# ---------------------------------------------------------------------------------------------------------------------------------
dir <- dirname(rstudioapi::getActiveDocumentContext()$path)
font_add_google(name = "Black Han Sans", family = "bhs")
theme_set(theme_gray(base_family = "NanumGothic"))