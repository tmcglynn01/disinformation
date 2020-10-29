#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Fri Oct 23 08:08:45 2020

@author: trevor

GA CODE MINER

Mines input raw html header data and mines Google Analytics codes
"""
import csv, re, sys
from os import chdir


chdir('/home/trevor/disinformation/data/output')
input_file = 'domain_htmlhead.csv'
output_file = 'mined_gacodes.csv'
reader_fn = ['domain_name', 'header_data']
writer_fn = ['domain_name', 'ga_code']
gacode_re = re.compile('(UA-\d+-\d+)')

csv.field_size_limit(sys.maxsize)

def create_reader_writer(inp, out):
    reader = csv.DictReader(inp, fieldnames=reader_fn)
    writer = csv.DictWriter(out, fieldnames=writer_fn)
    return reader, writer

def evaluate_scripts(text):
    results = []
    for e, line in enumerate(text):
        if line.startswith('<script>'):
            start, end = e, None
            cur = start
            while end is None:
                cur += 1
                try:
                    if text[cur].startswith('</script>'):
                        end = cur
                    results.append((start, end))
                except IndexError:
                    break
    return results
        
def evaluate_results(text, results):
    for tup in results:
        start, end = tup
        for line in text[start:end]:
            m = re.search(gacode_re, line)
            if m is not None:
                return m.group()

def main():             
    with open(input_file, 'r+') as inp, open(output_file, 'w+') as out:
        reader, writer = create_reader_writer(inp, out) 
        writer.writeheader()
        for row in reader:
            domain = row['domain_name']
            print('Checking...{}'.format(domain))
            header = row['header_data'].split('\n')
            matches = evaluate_scripts(header)
            ga_code = evaluate_results(header, matches)
            writer.writerow({'domain_name': domain, 'ga_code': ga_code})

main()