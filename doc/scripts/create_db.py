#!/usr/bin/env python3

import yaml
import sqlite3
from argparse import ArgumentParser

def parser():
    # parser information setup
    prog='create_db'
    description = 'Make SQLite3 database from yaml format input'
    usage = 'usage: python3 {} ' .format(__file__)
    usage += '[-o outfile] [-i infile]'
    parse = ArgumentParser(
                prog=prog,
                description=description, 
                usage=usage,
                add_help=True
                )

    # Input Filename
    parse.add_argument(
                '-i', 
                '--input',
                type=str,
                action='store',
                default='main.yml',
                help='Set input yaml file name (Default: main.yml)'
                )

    # Output Filename
    parse.add_argument(
                '-d', 
                '--dbName',
                type=str,
                action='store',
                default='main',
                help='Set database name (Defualt: main)'
                )
    return parse.parse_args()

def read_yaml(in_file):
    f = open(in_file, 'r')
    data = yaml.load(f, Loader=yaml.SafeLoader)
    print(data)

if __name__ == '__main__' :
    options = parser()
    in_file = options.input
    db_name = options.dbName

    read_yaml(in_file)
