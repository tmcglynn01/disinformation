#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Thu Oct 22 10:57:05 2020

@author: trevor
"""
import tabula
from os import chdir

inpdir = '/home/trevor/disinformation/data/input'
outdir = '/home/trevor/disinformation/data/output'
file = 'scrape.pdf'
chdir(inpdir)
tabula.convert_into(file, 'table_scrape.csv', pages='4-31')
