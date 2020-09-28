library(tidyverse)
library(lubridate)
setwd('C:\\rstudio\\disinformation')
dir.create('data\\output')
## This script is used to wrangle/munge data associated with disinformation.

fakeset_a <- read_csv('data\\AFake-kaggle.csv', col_types = 'fcfc') %>% glimpse


realset_a <- read_csv('data\\ATrue-kaggle.csv') %>% glimpse
fakeset_b <- read_csv('data\\fake-kaggle.csv') %>% glimpse
reopen_domains <- read_csv('data\\reopen-krebs.csv') %>% glimpse
news_articles <- read_csv('data\\news_articles-kaggle.csv') %>% glimpse
fnn_politics_fake <- read_csv('data\\fnn_politics_fake-kaggle.csv') %>% glimpse
fnn_politics_real <- read_csv('data\\fnn_politics_real-kaggle.csv') %>% glimpse
