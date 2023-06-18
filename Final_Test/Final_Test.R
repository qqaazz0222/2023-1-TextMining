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

# ---------------------------------------------------------------------------------------------------------------------------------
# 오즈비 분석
google <- readLines(paste(dir, "/google_keynote.txt", sep = ""), encoding = "UTF-8") %>% as_tibble() %>% mutate(company = "google")
apple <- readLines(paste(dir, "/apple_wwdc.txt", sep = ""), encoding = "UTF-8") %>% as_tibble() %>% mutate(company = "apple")
bind_speeches <- bind_rows(google, apple) %>% select(company, value)
speeches <- bind_speeches %>% mutate(value = str_replace_all(value, "[^가-힣]", " "), value = str_squish(value))
speeches <- speeches %>%
  unnest_tokens(input = value, output = word, token = extractNoun)
freq <- speeches %>%
  count(company, word) %>%
  filter(str_count(word)>1)
freq_wide <- freq %>% pivot_wider(names_from = company, values_from = n, values_fill = list(n=0))
freq_wide <- freq_wide %>% mutate(ratio_google = ((google+1)/(sum(google+1))), ratio_apple = ((apple+1)/(sum(apple+1))))
freq_wide <- freq_wide %>% mutate(odds_ratio = ratio_google/ratio_apple)
freq_wide %>% arrange(-odds_ratio)

freq <- freq %>% bind_tf_idf(term = word, document = company, n = n) %>%
  arrange(-tf_idf)
top10 <- freq %>% group_by(company) %>% slice_max(tf_idf, n = 10, with_ties = F)
top10$company <- factor(top10$company, levels = c("google", "apple"))
ggplot(top10, aes(x = reorder_within(word, tf_idf, company), y = tf_idf, fill = company)) +
  geom_col(show.legend = F) +
  coord_flip() +
  facet_wrap(~company, scales = "free", ncol = 2) +
  scale_x_reordered() +
  labs(x = NULL)

# ---------------------------------------------------------------------------------------------------------------------------------
# 의미망 분석
google <- read_csv(paste(dir, "/google_keynote.csv", sep = ""))
apple <- read_csv(paste(dir, "/apple_wwdc.csv", sep = ""))

# 토큰화 및 품사 분리
raw_google <- google %>% select(raw) %>% mutate(raw = str_replace_all(raw, "[^가-힣]", " "), raw = str_squish(raw), id = row_number())
raw_apple <- apple %>% select(raw) %>% mutate(raw = str_replace_all(raw, "[^가-힣]", " "), raw = str_squish(raw), id = row_number())
raw_google_pos <- raw_google %>% unnest_tokens(input = raw, output = word, token = SimplePos22, drop = F)
raw_google_pos %>% select(word, raw)
raw_apple_pos <- raw_apple %>% unnest_tokens(input = raw, output = word, token = SimplePos22, drop = F)
raw_apple_pos %>% select(word, raw)

# 품사 추출
noun_google = raw_google_pos%>% filter(str_detect(word, "/n")) %>% 
  mutate(word = str_remove(word, "/.*$"))
noun_google %>% select(word, raw)
noun_apple = raw_apple_pos%>% filter(str_detect(word, "/n")) %>% 
  mutate(word = str_remove(word, "/.*$"))
noun_apple %>% select(word, raw)
pvpa_google = raw_google_pos %>% filter(str_detect(word, "/pa|/pv")) %>% 
  mutate(word = str_replace(word, "/.*$", "다"))
pvpa_google %>% select(word, raw)
pvpa_apple = raw_apple_pos %>% filter(str_detect(word, "/pa|/pv")) %>% 
  mutate(word = str_replace(word, "/.*$", "다"))
pvpa_apple %>% select(word, raw)

# 결합
combine_google = bind_rows(noun_google, pvpa_google) %>% filter(str_count(word) >= 2) %>% arrange(id)
combine_google %>% select(word, raw)
combine_apple = bind_rows(noun_apple, pvpa_apple) %>% filter(str_count(word) >= 2) %>% arrange(id)
combine_apple %>% select(word, raw)

# 단어 동시 출현 빈도 분석
pair_google <- combine_google %>% pairwise_count(item = word, feature = id, sort = T)
pair_apple <- combine_apple %>% pairwise_count(item = word, feature = id, sort = T)

# 동시 출현 네트워크
graph_google <- pair_google %>% filter(n>=5) %>% as_tbl_graph()
graph_apple <- pair_apple %>% filter(n>=6) %>% as_tbl_graph()
graph_google
graph_apple

set.seed(1234)
ggraph(graph_google, layout = "fr") +
  geom_node_point(color = "#4285F4", size = 5) + 
  geom_edge_link(color = "#FBBD05", alpha = 0.5) + 
  geom_node_text(aes(label = name), repel = T, size = 5, family = "ng") +
  theme_graph()
ggraph(graph_apple, layout = "fr") +
  geom_node_point(color = "#FFACFB", size = 5) + 
  geom_edge_link(color = "#3C129C", alpha = 0.5) + 
  geom_node_text(aes(label = name), repel = T, size = 5, family = "ng") +
  theme_graph()


# ---------------------------------------------------------------------------------------------------------------------------------
# 토픽 모델링
google <- read_csv(paste(dir, "/google_keynote.csv", sep = ""))
apple <- read_csv(paste(dir, "/apple_wwdc.csv", sep = ""))

raw_google <- google %>%
  mutate(raw = str_replace_all(raw, "[^가-힣]", " "),
         raw = str_squish(raw)) %>%
  distinct(raw, .keep_all = T) %>%
  filter(str_count(raw, boundary("word")) >= 3)
raw_google <- raw_google %>%
  unnest_tokens(input = raw, output = word,
                token = extractNoun, drop = F) %>%
  filter(str_count(word) > 1) %>%
  group_by(id) %>%
  distinct(word, .keep_all = T) %>%
  ungroup() %>%
  select(id, word)
count_google <- raw_google %>%
  add_count(word) %>%
  filter(n <= 200) %>%
  select(-n)
count_google_doc <- count_google %>%
  count(id,word, sort = T)

raw_apple <- apple %>%
  mutate(raw = str_replace_all(raw, "[^가-힣]", " "),
         raw = str_squish(raw)) %>%
  distinct(raw, .keep_all = T) %>%
  filter(str_count(raw, boundary("word")) >= 3)
raw_apple <- raw_apple %>%
  unnest_tokens(input = raw, output = word,
                token = extractNoun, drop = F) %>%
  filter(str_count(word) > 1) %>%
  group_by(id) %>%
  distinct(word, .keep_all = T) %>%
  ungroup() %>%
  select(id, word)
count_apple <- raw_apple %>%
  add_count(word) %>%
  filter(n <= 200) %>%
  select(-n)
count_apple_doc <- count_apple %>%
  count(id,word, sort = T)

dtm_google <- count_google_doc %>%
  cast_dtm(document = id, term = word, value = n)
dtm_apple <- count_apple_doc %>%
  cast_dtm(document = id, term = word, value = n)

lda_google <- LDA(dtm_google, k = 8, method = "Gibbs",
                  control = list(seed = 1234))
lda_apple <- LDA(dtm_apple, k = 8, method = "Gibbs",
                 control = list(seed = 1234))

topic_google <- tidy(lda_google, matrix = "beta")
topic_apple <- tidy(lda_apple, matrix = "beta")

topic_google %>% arrange(-beta)
topic_apple %>% arrange(-beta)
# ---------------------------------------------------------------------------------------------------------------------------------
doc_topic <- tidy(lda_google, matrix = "gamma")
doc_topic %>% filter(document == 1) %>% summarise(sum_gamma = sum(gamma))
doc_class <- doc_topic %>% group_by(document) %>% slice_max(gamma, n = 1)
doc_class$document <- as.integer(doc_class$document)
doc_class %>% arrange(document)

new_google <- google %>% left_join(doc_class, by = c("id" = "document"))
new_google <- new_google %>% na.omit()
top_terms <- topic_google %>% group_by(topic) %>% slice_max(beta, n = 1, with_ties = F) %>% summarise(term = paste(term, collapse = ", "))
count_topic <- new_google %>% count(topic)
count_topic_word <- count_topic %>% left_join(top_terms, by = "topic") %>% mutate(topic_name = paste("TOPIC", topic))
ggplot(count_topic_word, aes(x = reorder(topic_name, n), y = n, fill = topic_name)) + geom_col(show.legend = F) +
  coord_flip() + geom_text(aes(label = n), hjust = -0.2) + geom_text(aes(label = term), hjust = 1.04, col = "white", fontface = "bold") +
  scale_y_continuous(limits = c(0, 200)) + labs(x = NULL)
# ---------------------------------------------------------------------------------------------------------------------------------

doc_topic <- tidy(lda_apple, matrix = "gamma")
doc_topic %>% filter(document == 1) %>% summarise(sum_gamma = sum(gamma))
doc_class <- doc_topic %>% group_by(document) %>% slice_max(gamma, n = 1)
doc_class$document <- as.integer(doc_class$document)
doc_class %>% arrange(document)

new_apple <- apple %>% left_join(doc_class, by = c("id" = "document"))
new_apple <- new_apple %>% na.omit()
top_terms <- topic_apple %>% group_by(topic) %>% slice_max(beta, n = 1, with_ties = F) %>% summarise(term = paste(term, collapse = ", "))
count_topic <- new_apple %>% count(topic)
count_topic_word <- count_topic %>% left_join(top_terms, by = "topic") %>% mutate(topic_name = paste("TOPIC", topic))
ggplot(count_topic_word, aes(x = reorder(topic_name, n), y = n, fill = topic_name)) + geom_col(show.legend = F) +
  coord_flip() + geom_text(aes(label = n), hjust = -0.2) + geom_text(aes(label = term), hjust = 1.04, col = "white", fontface = "bold") +
  scale_y_continuous(limits = c(0, 200)) + labs(x = NULL)