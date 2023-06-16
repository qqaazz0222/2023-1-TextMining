# ---------------------------------------------------------------------------------------------------------------------------------
# 라이브러리 설치
# install.packages('rstudioapi')
# install.packages('dplyr')
# install.packages("gridExtra")
# 라이브러리 부착
library(rstudioapi)
library(dplyr)
library(readr)
library(stringr)
library(ggplot2)
library(tidytext)
# ---------------------------------------------------------------------------------------------------------------------------------

dir <- dirname(rstudioapi::getActiveDocumentContext()$path)

# ---------------------------------------------------------------------------------------------------------------------------------

# 데이터 불러오기
ai_news <- readLines(paste(dir, "/ainews.txt", sep = ""), encoding = "UTF-8")

# 텍스트 전처리 (불필요 문자 제거, 연속된 공백 제거, tibble 구조로 변경)
new <- ai_news %>% str_replace_all("[^가-힣]", replacement = " ") %>% str_squish() %>% as_tibble()

# 토큰화(단어)
word_space <- new %>% unnest_tokens(input = value, output = word, token = "words")
# 단어 빈도 구하기
word_space <- word_space %>% count(word, sort = T)


