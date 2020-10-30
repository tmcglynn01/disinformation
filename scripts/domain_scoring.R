# Provide a weighted score on domain names based on the keywords used
library(tidyverse)
library(tidytext)


df <- read_csv('data/datasets/fake_real_domains_combined (copy).csv',
               col_types = 'iccc_TTT_____cciiidddd') %>% 
  mutate(dom_split = mapply(str_split, dom_split, ' '))
df <- df %>% drop_na(dom_age_days)

# Clean and factor registrars for the top 300
df <- df %>% 
  mutate(registrar = mapply(str_remove_all, registrar, 
                            '\\bllc|\\bltd|\\binc|\\bcorp|\\bco')) %>% 
  mutate(registrar = mapply(str_trim, registrar, side = 'right')) %>% 
  mutate(registrar = fct_lump(registrar, n = 300))
df$registrar <- as.character(df$registrar)

# Analysis of words used in fake domain names
fk <- df %>% filter(trust == 'fake')
word_analysis <- tibble(text = flatten_chr(fk$dom_split))
word_analysis <- word_analysis %>% 
  unnest_tokens(word, text) %>% 
  count(word, sort = TRUE)

# Find frequency and counts
summ_word <- word_analysis %>% 
  anti_join(get_stopwords()) %>%                          # Remove stop words
  filter(str_length(word) > 1, n >= 2) %>% 
  mutate(samp_freq = n/sum(n))

# Output frequecy table
write_csv(summ_word, 'data/datasets/fake_domain_word_freq.csv')
# Output redone df
df <- df %>% mutate(dom_split = mapply(str_c, dom_split, collapse = ' '))
write_csv(filter(df, !is.na(registrar)), # Mostly foreign language
          'data/datasets/fake_real_domains_combined.csv')

reg_scores <- fk %>% 
  count(registrar) %>% 
  arrange(desc(n)) %>% 
  mutate(reg_score = n/nrow(fk))
m <- 1/max(reg_scores$reg_score)
reg_scores$reg_score <- reg_scores$reg_score * m
reg_scores
write_csv(reg_scores, 'data/datasets/reg_scores.csv')
