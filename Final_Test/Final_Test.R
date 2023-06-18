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

# 데이터 불러오기
google <- readLines(paste(dir, "/google_keynote.txt", sep = ""), encoding = "UTF-8")
apple <- readLines(paste(dir, "/apple_wwdc.txt", sep = ""), encoding = "UTF-8")

# 텍스트 전처리 (불필요 문자 제거, 연속된 공백 제거, tibble 구조로 변경)
new_google <- google %>% str_replace_all("[^가-힣]", replacement = " ") %>% str_squish() %>% as_tibble()
new_apple <- apple %>% str_replace_all("[^가-힣]", replacement = " ") %>% str_squish() %>% as_tibble()

# 토큰화(단어)
word_google <- new_google %>% unnest_tokens(input = value, output = word, token = extractNoun)
word_apple <- new_apple %>% unnest_tokens(input = value, output = word, token = extractNoun)

# 단어 빈도 구하기, 단어 길이 1 보다 긴 행만 추출
word_google <- word_google %>% count(word, sort = T)  %>% filter(str_count(word)>1)
word_apple <- word_apple %>% count(word, sort = T)  %>% filter(str_count(word)>1)
top_20_google <- word_google %>% head(20)
top_20_apple <- word_apple %>% head(20)

ggplot(head(top_20_google), aes(x = reorder(word, n), y= n)) + 
  geom_col() + 
  coord_flip() +
  geom_text(aes(label = n), hjust = -0.1) +
  labs(x = NULL) +
  theme(text = element_text(family = "ng"))

ggplot(head(top_20_apple), aes(x = reorder(word, n), y= n)) + 
  geom_col() + 
  coord_flip() +
  geom_text(aes(label = n), hjust = -0.1) +
  labs(x = NULL) +
  theme(text = element_text(family = "ng"))

word_google %>% ggplot(aes(label = word, size = n, col = n)) +
  geom_text_wordcloud(seed = 1234, family = "bhs") +
  scale_radius(limits = c(3, NA), range = c(3, 30)) +
  scale_color_gradient(low = "#4285F4", high = "#FBBD05") +
  theme_minimal()

word_apple %>% ggplot(aes(label = word, size = n, col = n)) +
  geom_text_wordcloud(seed = 1234, family = "bhs") +
  scale_radius(limits = c(3, NA), range = c(3, 30)) +
  scale_color_gradient(low = "#FFACFB", high = "#3C129C") +
  theme_minimal()