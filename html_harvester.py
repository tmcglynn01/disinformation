#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Thu Oct 22 08:24:40 2020

@author: trevor

Requests an HTML webpage and saves its <head> data for further processind
"""
import re
import pandas as pd
from urllib.request import Request, urlopen
from urllib.error import URLError
from bs4 import BeautifulSoup
from os import chdir
from collections import deque
import csv

chdir('/home/trevor/disinformation/data/output')
re_gacode = re.compile('.*(UA-\d+-\d+).*')
input_file = 'ga_query_doms.csv'
output_file = 'domain_head_gacodes.csv'
results = deque()

def open_page(url):
    r = Request(url, headers={'User-Agent': 'Mozilla/5.0'})
    try:
        page = urlopen(r).read()
        soup = BeautifulSoup(page, 'html.parser')
        return soup
    except URLError:
        pass
def gather_gacode(head):
    ga_code = re.search(re_gacode, str(head))
    if ga_code is not None:
        return ga_code[1]
def scrape_domain(domain):
    url = 'https://' + domain
    print('Querying domain...{}'.format(domain))
    soup = open_page(url)
    if soup is not None:
        ga_code = gather_gacode(soup.head)
        print('Found GA code: {}'.format(ga_code))
        return ga_code
    else:
        print('Failed to find code for {}'.format(domain))
        return None

df = pd.read_csv(input_file)  
with open('ga_codes_extract.csv', 'w', newline='') as csvfile:
    fieldnames = ['domain_name', 'ga_code']
    writer = csv.DictWriter(csvfile, fieldnames=fieldnames)

    writer.writeheader()
    for dom in df['domain_name']:
        code = scrape_domain(dom)
        writer.writerow({'domain_name': dom, 'ga_code': code})