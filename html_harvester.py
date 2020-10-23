#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Thu Oct 22 08:24:40 2020

@author: trevor

Requests an HTML webpage and saves its <head> data for further processind
"""
import pandas as pd
from urllib.request import Request, urlopen
from urllib.error import URLError
from bs4 import BeautifulSoup
from os import chdir
import csv

chdir('/home/trevor/disinformation/data/output')
input_file = 'ga_query_doms.csv'
output_file = 'domain_htmlhead.csv'

def open_page(url):
    r = Request(url, headers={'User-Agent': 'Mozilla/5.0'})
    try:
        page = urlopen(r).read()
        soup = BeautifulSoup(page, 'html.parser')
        print('Page opened!')
        return soup
    except URLError:
        print('Error opening page. Continuing...')
        pass
    

def scrape_domain(domain):
    url = 'https://' + domain
    print('Querying domain...{}'.format(domain))
    soup = open_page(url)
    if soup is not None:
        try:
            html_header = soup.head
            print('Returning header data for domain {}'.format(domain))
            return html_header
        except:
            print('Error retrieving head data. Continuing...')
            return None
    else:
        print('Failed to find code for {}'.format(domain))
        return None

df = pd.read_csv(input_file)  
with open(output_file, 'w', newline='') as csvfile:
    fieldnames = ['domain_name', 'header_data']
    writer = csv.DictWriter(csvfile, fieldnames=fieldnames)
    writer.writeheader()
    i = 0
    while i < len(df['domain_name']):
        target = df['domain_name'][i]
        data = scrape_domain(target)
        writer.writerow({'domain_name': target, 'header_data': data})
        i += 1