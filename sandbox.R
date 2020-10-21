# Script sandbox
library(dplyr)
library(stringr)
library(forcats)
library(ggplot2)
library(tldextract)
library(rvest)
library(readr)

PATH <- 'data/input/'
# Kaggle datasets
true <- paste(PATH, 'ATrue-kaggle.csv', sep = '') 
false <- paste(PATH, 'AFake-kaggle.csv', sep = '') 
readr::read_csv(true) %>% glimpse()
readr::read_csv(false) %>% glimpse()
file.remove(c(true, false))
rm(true, false)
## Title, text, subject, date... maybe not that newsworthy


fake <- paste(PATH, 'fake-kaggle.csv', sep = '') %>% readr::read_csv
fake %>% glimpse
drop_columns <- c('uuid', 'ord_in_thread', 'crawled')
text_split <- function(x) { sapply(str_split(x, ' '), length) }
`%ni%` <- Negate(`%in%`)
STRIP <- '[[:digit:]]|[[:punct:]]'
token <- function(df) {
  df %>% 
    mutate(title = tolower(title) %>% str_remove_all(STRIP)) %>% 
    mutate(title_tokens = str_split(title, '\\s+')) %>% 
    mutate(text = tolower(text) %>% str_remove_all(STRIP)) %>% 
    mutate(text_tokens = str_split(text, '\\s+'))
}
fake <- fake %>% 
  select(-!!drop_columns) %>% 
  type_convert(col_types = 'f?ccfffdfdfdddddf') %>% 
  token %>% 
  mutate(text_length = lapply(text_tokens, length) %>% unlist) %>% 
  mutate(title_length = lapply(title_tokens, length) %>% unlist) %>% 
  group_by(site_url) %>% 
  arrange(site_url, published %>% desc)
unique(fake$site_url) %>% length
# 244 unique domains
range(fake$published)
# Published over a 1 month period during 2016 election
ggplot(fake, aes(published)) +
  geom_histogram() +
  scale_x_datetime(date_breaks = '3 days')
summary(fake$author)

fake_domains <- fake %>% select(site_url) %>% unique
file.copy('data/input/fake-kaggle.csv', 'data/input/analysis/fake-kaggle.csv')
file.remove('data/input/fake-kaggle.csv')

## FNN Politics Fake
fake <- paste(PATH, 'fnn_politics_fake-kaggle.csv', sep = '')
fake <- readr::read_csv(fake) %>% glimpse
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

rm(fake_news,df, drop_columns, false, link, STRIP, tld, true) #cleanup

fake <- readr::read_csv('data/input/news_articles-kaggle.csv')
target <- 'data/input/news_articles-kaggle.csv'
fake %>% glimpse
file.copy(target, 'data/input/analysis/kaggle-best.csv')
file.remove(target)
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
fake <- readr::read_csv(target)
fake %>% glimpse()
file.copy(target, 'data/input/analysis/reopen-krebs.csv')
file.remove(target)
fake$`DOMAIN NAME`
fake_domains <- union(fake_domains, fake %>% select(site_url = 1))

target <- 'data/input/poynter_covid_claims_data.csv'
readr::read_csv(target)%>% glimpse()
file.remove(target)
file.remove('data/input/russian_ads.json')

target <- 'data/input/us_house_psci/scottcame-us-house-psci-social-media-ads/data/facebookads.csv'
readr::read_csv(target) %>% glimpse()
file.copy(target, 'data/input/analysis/')
unlink('data/input/us_house_psci/', recursive = TRUE, force = TRUE)

target <- 'data/input/ieee source/fake news detection(FakeNewsNet)/fnn_dev.csv'
readr::read_csv(target) %>% filter(label_fnn == 'fake') %>% glimpse() %>%
  select(sources)
## Seems like this focuses on misinformation as opposed to disinformation?
target <- 'data/input/ieee source/fake news detection(LIAR)/liar_dev.csv'
readr::read_csv(target) %>% glimpse()
## IBID
unlink('data/input/ieee source/', recursive = TRUE, force = TRUE)

target <- 'data/input/fnn_harvard/politifact_fake.csv'
readr::read_csv(target) %>% glimpse
## Already done elsewhere
unlink('data/input/fnn_harvard/', recursive = TRUE, force = TRUE)

target <- 'data/input/dataworld/d1gi-ten-gop-earned-media/data/ten_gop.csv'
readr::read_csv(target) %>% select(source_url)
# Move for analysis
file.copy(target, 'data/input/analysis/')

readr::write_csv(fake_domains, 'data/output/fake_domains.csv')

target <- 'data/input/top-1m.csv'
top_websites <- readr::read_csv(target, col_names = c('rank', 'site_url'),
                                col_types = 'ic')
top_20000 <- top_websites %>% slice_head(n = 20000)
sample_40000 <- top_websites %>% 
  slice_min(rank, n = 100000) %>% 
  slice_tail(n = 80000) %>% 
  slice_sample(n = 40000)
top_websites <- union(top_20000, sample_40000)
readr::write_csv(top_websites %>% select(2), 'data/output/top_websites.csv')
rm(top_20000, sample_40000)  

domains <- readr::read_csv('data/output/domains_whois.csv')
domains <- domains %>% readr::type_convert(col_types = 'fffTTTcccfcfcffcf')
domains$domain_name <- str_to_lower(domains$domain_name)
domains %>% distinct(domain_name)
domains$domain_name[duplicated(domains$domain_name)]
domains <- domains %>% 
  distinct(domain_name, .keep_all = TRUE) %>% 
  filter(is.na(domain_name) == FALSE)

ggplot(domains %>% 
         group_by(registrar) %>%
         summarise(count = n()) %>% 
         top_n(25) %>% 
         arrange(count %>% desc) %>% 
         filter(registrar != 'GoDaddy.com, LLC'),
       aes(reorder(registrar, count, ), count)) +
  geom_bar(stat = 'identity') +
  coord_flip()

  