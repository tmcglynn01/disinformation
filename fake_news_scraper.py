#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Thu Oct 22 09:48:04 2020

@author: trevor

This script pulls in some additional fake news sources using a guide
published by Berkeley: https://guides.lib.berkeley.edu/fake-news
"""
import re
from urllib.request import Request, urlopen
from bs4 import BeautifulSoup
import csv
from os import chdir

chdir('/home/trevor/disinformation/data/output')
dailydot = 'https://www.dailydot.com/debug/fake-news-sites-list-facebook/'

def open_page(url):
    r = Request(url, headers={'User-Agent': 'Mozilla/5.0'})
    page = urlopen(r).read()
    soup = BeautifulSoup(page, 'html.parser')
    return soup

# DailyDot
cur = open_page(dailydot)
dailydot_re = re.compile('\d+\.\s(\w+\.\w+)$')
results = cur.find_all(string=re.compile(dailydot_re))
for e, res in enumerate(results):
    results[e] = re.match(dailydot_re, res)[1]
print(results)

file = open('dailydot.csv', 'w+', newline ='') 
with file:     
    write = csv.writer(file) 
    write.writerow(results)