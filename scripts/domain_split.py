#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Mon Oct 26 15:17:30 2020

@author: trevor
"""
from segment.segment.segmenter import Analyzer
import csv
t = Analyzer('anchor')

infile = 'data/output/domain_split_file.csv'
outfile = 'data/output/final_df.csv'
headers = ['rank', 'domain', 'tld', 'registrar', 'whois_server', 
           'updated_date', 'creation_date', 'expiration_date', 'name_servers',
           'dnssec', 'org', 'city', 'state', 'zipcode', 'country', 'trust',
           'dom_split']   

def create_reader_writer(infile=infile, outfile=outfile):
    reader = csv.DictReader(infile)
    writer = csv.DictWriter(outfile, headers, extrasaction='ignore')
    return reader, writer

def split_domain(domain): return t.segment(domain)

def main():             
    with open(infile, 'r+') as inp, open(outfile, 'w+') as out:
        reader, writer = create_reader_writer(inp, out) 
        writer.writeheader()
        for line in reader:
            domain = line['domain']
            print('Checking...{}'.format(domain))
            dom_split = split_domain(domain)
            line['dom_split'] = dom_split
            writer.writerow(line)
            
main()

