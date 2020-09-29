library(tidyverse)
library(lubridate)


setwd('C:/github/disinformation/')
dir.create('data/output', showWarnings = FALSE)
## This script is used to wrangle/munge data associated with disinformation.

fakeset_a <- read_csv('data/AFake-kaggle.csv', col_types = 'ccfc') %>% glimpse
fka_clean <- fakeset_a %>% 
    mutate(date = parse_date_time(date, orders = c('mdy', 'dmy')),
           title_length = str_length(title),
           text_length = sapply(strsplit(text, ' '), length)) %>%
    arrange(date, subject)
realset_a <- read_csv('data/ATrue-kaggle.csv', col_types = 'ccfc')
rla_clean <- realset_a %>%
    mutate(date = parse_date_time(date, orders = c('mdy', 'dmy')),
           title_length = str_length(title),
           text_length = sapply(strsplit(text, ' '), length)) %>%
    arrange(date, subject)
rm(fakeset_a, realset_a)

## FIXME: ADD DATA DESCRIPTION
fakeset_b <- read_csv('data/fake-kaggle.csv')
drop_columns <- c('uuid', 'crawled')
domain_extract <- '\\w+\\.\\w{2,}(?=/)'
fkb_clean <- fakeset_b %>%
    select(-!!drop_columns) %>%
    arrange(published, country, language) %>% 
    separate(site_url, c('domain_name', 'tld')) %>% 
    mutate(author = parse_factor(author),
           language = parse_factor(language),
           domain_name = parse_factor(domain_name),
           tld = parse_factor(tld),
           country = parse_factor(country),
           type = parse_factor(type),
           main_img_domain = str_extract(main_img_url, domain_extract),
           title_length = str_length(title),
           text_length = sapply(strsplit(text, ' '), length)) %>%
    arrange(published, country, language)
rm(fakeset_b)

reopen_domains <- read_csv('data/reopen-krebs.csv')
reopen_clean <- reopen_domains %>% 
    select_all(~str_replace(., ' ', '_')) %>%
    select_all(tolower) %>%
    rename(active = `active?`) %>%
    separate(domain_name, c('domain', 'tld')) %>%
    mutate(date = parse_date_time(date, c('mdy', '%m-%d%y')),
           registrar = parse_factor(registrar),
           registrant = parse_factor(registrant),
           timestamp = parse_date_time(timestamp, 'ymd HMS'),
           state = recode_factor(state,
                                 'NEV' = 'NV',
                                 'FLA' = 'FL',
                                 'WIS' = 'WI',
                                 'KAN' = 'KS',
                                 'ALA' = 'AL')) %>%
    arrange(date, state, timestamp)
reopen_clean %>% glimpse
un_reopen_notes <- unique(reopen_clean$notes)

# Adds email and Google Analytics ID columns where detected
reopen_clean <- reopen_clean %>%
    select(notes) %>%
    mutate(notes_emails = str_extract(notes, '\\S+@\\S+\\.\\S+'),
           notes_ga = str_extract(notes, 'UA-\\d+-\\d+'))
rm(reopen_domains)

news_articles <- read_csv('data\\news_articles-kaggle.csv',
                          col_types = 'fTccfccffccl') %>% glimpse
news_articles %>%
    mutate(title_length = sapply(str_split(title, ' '), length),
           text_length = sapply(str_split(text, ' '), length)) %>%
    separate(site_url, c('domain', 'tld')) %>%
    mutate(img_domain = str_extract(main_img_url, domain_extract),
           type = parse_factor(type))
    

fnn_politics_fake <- read_csv('data\\fnn_politics_fake-kaggle.csv') %>% glimpse
fnn_politics_real <- read_csv('data\\fnn_politics_real-kaggle.csv') %>% glimpse
