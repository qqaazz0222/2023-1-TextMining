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
# ---------------------------------------------------------------------------------------------------------------------------------
# 문제2. 가장 자주 사용된 단어 추출 및 빈도 그래프 만들기
# [txt 파일 읽어오기] 뉴스 제목 가져오기
news_data <- readLines(paste(dir, "/total.txt", sep = ""), encoding = "UTF-8")
# [txt -> tibble 형태 변환] 토큰 추출
news_tibble <- str_squish(news_data) %>% as_tibble()
# [토큰 추출]
news <- news_tibble %>% unnest_tokens(input = value, output = word, token = "words")
# [단어 빈도]
news <- news %>% count(word, sort = T)
# [전처리] 한글자인 단어는 제외 한 후, 상위 20개의 단어 추출
result <- news %>% filter(str_count(word) > 1)
result <- result %>% head(20)
# [그래프 그리기]
ggplot(result, aes(x = n, y=reorder(word,n))) + geom_col() + xlab("단어 수(n)") + ylab("단어")

# ---------------------------------------------------------------------------------------------------------------------------------
# 문제3. 오즈비 또는 TF-IDF 활용하여 분석하기
# [CSV 불러오기]
news_csv <- read_csv(paste(dir, "/news_data.csv", sep = ""))
# [전처리]
news <- news_csv %>% mutate(value = str_replace_all(value, "[^가-힣]", " "), value = str_squish(value))
# [토큰화]
news <- news %>% unnest_tokens(input = value, output = word, token = extractNoun)
# [단어 빈도 구하기]
freq <- news %>% count(time, word) %>% filter(str_count(word) > 1)
# [TF_IDF 구하기, 내림차순 정렬]
freq <- freq %>% bind_tf_idf(term = word, document = time, n = n) %>% arrange(-tf_idf)
# [상위 10개의 데이터 가져오기]
top_20 <- freq %>% group_by(time) %>% slice_max(tf_idf, n = 20, with_ties = F)
# [범주형으로 변환]
top20 <- factor(top_20$time, levels = c("before, after"))
# [막대 그래프 그리기]
ggplot(top_20, aes(x = reorder_within(word, tf_idf, time), y = tf_idf, fill = time)) +
  geom_col(show.legend = F) +
  coord_flip() + 
  facet_wrap(~time, scales = "free", ncol = 2) +
  scale_x_reordered() +
  labs(x = "단어", y = "빈도")
