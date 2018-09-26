# Test Mine HTDD
#library(tm)
library(tidytext)
library(dplyr)
library(tidyr)

htdd = readRDS("../roadworksUK/data/htdd.Rds")

foo = htdd[1:1000000,]
text_df <- data_frame(id = 1:nrow(foo), text = foo$description)


bigrams <- text_df %>%
  unnest_tokens(bigram, text, token = "ngrams", n = 2) %>%
  count(bigram, sort = TRUE)

bigrams_separated <- bigrams %>%
  separate(bigram, c("word1", "word2","word3"), sep = " ")

bigrams_filtered <- bigrams_separated %>%
  filter(!word1 %in% stop_words$word) %>%
  filter(!word2 %in% stop_words$word) %>%
  filter(!word3 %in% stop_words$word)

# new bigram counts:
bigram_counts <- bigrams_filtered %>%
  count(word1, word2, word3, sort = TRUE)

bigram_counts




words_df <- unnest_tokens(tbl = text_df, output = word, input = text,
                         token = "words", to_lower = TRUE)
nrow(words_df)
words_df <- anti_join(words_df, stop_words) # Remove common like the. and, I
nrow(words_df)
text_count <- count(words_df, word, sort = T)
#text_count = text_count[order(text_count$n, decreasing = T),]
head(text_count, 20)
#
#
#
#
# write.csv(text_count,"twitter/data/word_count.txt")
