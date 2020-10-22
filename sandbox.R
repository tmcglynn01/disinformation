# Script sandbox
library(rvest)
library(tidyverse)
library(get)

PATH <- 'data/input/'
`%ni%` <- Negate(`%in%`)

## FUNCS
text_split <- function(x) { sapply(str_split(x, ' '), length) }
token <- function(df) {
  df %>% 
    mutate(title = tolower(title) %>% str_remove_all(STRIP)) %>% 
    mutate(title_tokens = str_split(title, '\\s+')) %>% 
    mutate(text = tolower(text) %>% str_remove_all(STRIP)) %>% 
    mutate(text_tokens = str_split(text, '\\s+'))
}

## CONST
STRIP <- '[[:digit:]]|[[:punct:]]' 

fake <- read_csv('data/input/fake-kaggle.csv')
drop_columns <- c('uuid', 'ord_in_thread', 'crawled')
fake <- fake %>% 
  select(-!!drop_columns) %>% 
  type_convert(col_types = 'f?ccfffdfdfdddddf') %>% 
  token %>% 
  mutate(text_length = lapply(text_tokens, length) %>% unlist) %>% 
  mutate(title_length = lapply(title_tokens, length) %>% unlist) %>% 
  group_by(site_url) %>% 
  arrange(site_url, published %>% desc)
fake_domains <- fake %>% select(site_url) %>% unique
file.copy('data/input/fake-kaggle.csv', 'data/input/analysis/fake-kaggle.csv')
file.remove('data/input/fake-kaggle.csv')

## FNN Politics Fake
fake <- paste(PATH, 'fnn_politics_fake-kaggle.csv', sep = '')
fake <- read_csv(fake) %>% glimpse
url_match <- '^(?:https?:\\/\\/)?(?:www\\.)?([^\\/\\r\\n]+)(\\/[^\\r\\n]*)?'
web_archive_rm <- '^https:\\/\\/web.archive.org\\/.*(?=http)'
fake <- fake %>% 
  select(-tweet_ids) %>% 
  # strip http
  mutate(news_url = str_remove(news_url, web_archive_rm)) %>% 
  mutate(site_url = str_replace(news_url, url_match, replacement = '\\1'))
fake_domains <- fake %>% 
  mutate(site_url = str_remove(site_url, ':\\d+$')) %>%
  group_by(site_url) %>% 
  summarise(site_url) %>% 
  union(fake_domains)
dir.create('data/input/analysis')
file.copy('data/input/fnn_politics_fake-kaggle.csv', 'data/input/analysis/fnn_politics_fake-kaggle.csv')
file.remove(c('data/input/fnn_politics_fake-kaggle.csv', 'data/input/fnn_politics_real-kaggle.csv'))

rm(drop_columns) #cleanup

fake <- read_csv('data/input/kaggle-best.csv')
file.copy('data/input/kaggle-best.csv', 'data/input/analysis/kaggle-best.csv')
file.remove('data/input/kaggle-best.csv')
fake_domains <- fake %>% select(site_url) %>% union(fake_domains)

## Scrape from NYT report on pay to play media
# https://www.nytimes.com/2020/10/20/technology/timpone-network-pay-to-play-local-news.html

link <- 'https://docs.google.com/spreadsheets/u/1/d/e/2PACX-1vTY6gW8su8k-BxuQo6CkwEDfsQq3TnVdqEOOqtjOeZ6YeYiXyZ-ZjZnN6pDKmQHpfZ9sXhUHmnduKUr/pubhtml?gid=0&single=true'
fake_news <- read_html(link)
fake_news <- fake_news %>% 
  html_node('table') %>% html_table(header=FALSE) %>% tbl_df
fake_news <- fake_news %>% 
  select(site_url = 4) %>% 
  slice(-(1:3))
fake_domains <- union(fake_domains, fake_news)

target <- 'data/input/reopen-krebs.csv'
fake <- read_csv(target)
fake %>% glimpse()
file.copy(target, 'data/input/analysis/reopen-krebs.csv')
file.remove(target)
fake$`DOMAIN NAME`
fake_domains <- union(fake_domains, fake %>% select(site_url = 1))
fake_domains <- fake_domains %>% select(domain_name = site_url)

## Add in dailydot scrape
fake <- read_csv('data/output/dailydot.csv',col_names = 'domain_name')
fake_domains <- fake %>% union(fake_domains)
## Add in table scrape
fake <- read_csv('data/output/table_scrape.csv') %>% select(domain_name = 1)
fake_domains <- fake %>% union(fake_domains)
fake_domains <- fake_domains %>% distinct(domain_name, .keep_all = TRUE)

## Take file and scrape whois data
write_csv(fake_domains, 'data/output/fake_domains.csv')
rm(fake, fake_news) # cleanup

##
# top_websites <- read_csv('data/input/top-1m.csv', 
#                          col_names = c('rank', 'site_url'),
#                          col_types = 'ic')
# top_20000 <- top_websites %>% slice_head(n = 20000)
# sample_40000 <- top_websites %>% 
#   slice_min(rank, n = 100000) %>% 
#   slice_tail(n = 80000) %>% 
#   slice_sample(n = 40000)
# top_websites <- union(top_20000, sample_40000)
# #write_csv(top_websites %>% select(2), 'data/output/top_websites.csv')
# rm(top_20000, sample_40000)  

## Add the top domains whois df
top_domains_whois <- read_csv('data/output/top_domains_whois.csv') 
top_domains_whois <- top_domains_whois %>% 
  type_convert(col_types = 'fffTTTcccfcfcffcf') %>% 
  distinct(domain_name, .keep_all = TRUE) %>% 
  filter(is.na(domain_name) == FALSE) %>% 
  mutate(trust = as.factor('initial trust'),
         domain_name = str_to_lower(domain_name))

## Add the fake domains whois df
fake_domains_whois <- read_csv('data/output/fake_domains_whois.csv') 
fake_domains_whois <- fake_domains_whois %>% 
  type_convert(col_types = 'fffTTTcccfcfcffcf') %>% 
  distinct(domain_name, .keep_all = TRUE) %>% 
  filter(is.na(domain_name) == FALSE) %>%
  mutate(domain_name = str_to_lower(domain_name))

## Check which domains show in both lists, manually adjust
both <- intersect(top_domains_whois$domain_name, fake_domains_whois$domain_name)
selection <- c(0,0,0,0,0,0,0,0,0,0,
               0,0,1,0,0,1,1,0,0,0,
               0,0,0,0,1,1,0,1,0,0,
               0,0,0,1,1,0,0,1,0,0,
               1,0,1,0,0,0,0,0,0,1,
               1,0,0,0,0,1,0,0,0,0,
               1,0,1,1,0,0,0,0,1,0,
               1,0,1,0,0,1,0,0,1,1,
               1,0,0,0,1)
fake <- both[as.logical(selection)]
real <- both[!as.logical(selection)]
# Filter out of the top ones...
top_domains_whois <- top_domains_whois %>% filter(domain_name %ni% fake)
# And add to & distinct in fake_domains
fake_domains_whois <- fake_domains_whois %>% 
  filter(domain_name %ni% real) %>% 
  distinct(domain_name, .keep_all = TRUE) %>% 
  mutate(trust = 'fake')
fake_domains_whois %>% View
top_domains_whois %>% View
# Combine datasets and add site ranking
alexa <- read_csv('data/input/top-1m.csv', 
                  col_names = c('rank', 'domain_name'),
                  col_types = 'ic')
all_web_whois <- union(fake_domains_whois, top_domains_whois)
all_web_whois <- right_join(alexa, all_web_whois, by = 'domain_name')
rm(alexa, fake_domains_whois, top_domains_whois, fake_domains, top_websites)
all_web_whois %>% View

# Let's audit the data with some known disinformation sites
search_domain <- function(df, dom){
  df %>% 
    filter(.data$domain_name == dom) %>% 
    select(.data$rank, .data$domain_name, .data$trust)
}
search_domain(all_web_whois, '8kun.top')
# Showing initial trust (fail)
search_domain(all_web_whois, 'breitbart.com')
# Showing initial trust (fail)
search_domain(all_web_whois, 'google.com')
search_domain(all_web_whois, '100percentfedup.com')
# Looks OK so far, though will need some correction
colnames(all_web_whois)

all_web_whois %>% 
  select(-c(9, 10, 12, 14)) %>% 
  
