# ---------------------------------------------------------------------------------------------------------------------------------
# 라이브러리 부착
library(rstudioapi)
library(dplyr)
library(readr)
library(stringr)
library(ggplot2)
library(tidyr)
library(tidytext)
library(tidygraph)
library(KoNLP)
useNIADic()
library(showtext)
library(ggwordcloud)
library(widyr)
library(ggraph)
library(textclean)
library(tm)
library(topicmodels)
# ---------------------------------------------------------------------------------------------------------------------------------

dir <- dirname(rstudioapi::getActiveDocumentContext()$path)
font_add_google(name = "Nanum Gothic" , family = "ng")
font_add_google(name = "Black Han Sans" , family = "bhs")
showtext_auto()

# ---------------------------------------------------------------------------------------------------------------------------------
