#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Fri Oct 23 08:08:45 2020

@author: trevor

GA CODE MINER

Mines input raw html header data and mines Google Analytics codes
"""
import csv, re
from os import chdir


chdir('/home/trevor/disinformation/data/output')
input_file = 'domain_htmlhead.csv'
output_file = 'mined_gacodes.csv'
reader_fn = ['domain_name', 'header_data']
writer_fn = ['domain_name', 'ga_code']
gacode_re = re.compile('UA-\d+-\d+')

def create_reader_writer():
    reader = csv.DictReader(inp, fieldnames=reader_fn)
    writer = csv.DictWriter(out, fieldnames=writer_fn)
    return reader, writer

def evaluate_scripts(reader_obj):
    results = []
    text = reader_obj.split('\n')
    for e, line in enumrate(text):
        if line.startswith('<script>'):
            start, end = e, None
            cur = start
            while end is None:
                cur += 1
                if test[cur].startswith('</script>'):
                    end = cur
                results.append((start, end))
    return results
        
def evaluate_results(results):
    for tup in results:
	start, end = tup[0], tup[1]
	for line in test[start:end]:
		m = re.search(gacode_re, y)
		if m:
			return m   

def main():             
    with open(input_file, 'r+') as inp, open(output_file, 'w+') as out:
        reader, writer = create_reader_writer() 
        writer.writeheader()
        for row in reader:
            matches = evaluate_scripts(row)
            ga_code = evaluate_results(matches)
            writer.writerow(row['domain_name'], ga_code)