# -*- coding: utf-8 -*-
"""
Spyder Editor

This is a temporary script file.
"""
import whois
import os
from csv import DictWriter, reader
from collections import deque

os.chdir('/home/trevor/disinformation/data/output')
FIELDNAMES = ['domain_name', 'registrar', 'whois_server', 'updated_date', 
              'creation_date', 'expiration_date', 'name_servers', 'status',
              'emails', 'dnssec', 'name', 'org', 'address', 'city', 'state', 
              'zipcode', 'country']
SKIPS = deque()


def parse_rows(target, writer):
    """
        Parses rows of a targeted csv file and runs whois query on each domain
        Returns a row written to the target file or appends a list of
        skipped domains
    """
    for row in target:
        site = row[0]
        print('Running whois query on...{}'.format(site))
        try:
            w = whois.whois(site)
            for key, val in w.items():
                t_val = type(val)
                if (key != 'name_servers') and (t_val == list):
                    w[key] = val[0] # Take the foremost value
            print('Success! ', end='')
        except Exception:
            print('No match for {}. Adding to skips.'.format(site))
            SKIPS.append(site)
            pass
        writer.writerow(w)
  
        
def read_write(inp, outp):
    """
        Acts as the reader and writer for the source and target csvs
    """
    with open(inp, 'r') as source, open(outp, 'w') as target:      
        writer = DictWriter(target, fieldnames=FIELDNAMES, extrasaction='ignore')
        target = reader(source)
        writer.writeheader()
        parse_rows(target, writer)
        
def main():
    read_write('fake_domains.csv', 'domains_whois.csv')
    read_write('top_websites.csv', 'top_domains_whois.csv')
    
main()