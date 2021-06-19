#!/usr/bin/python3
import os
import sys
import re
from argparse import ArgumentParser

def parser():
    # parser information setup
    prog='dmp2prg'
    description = 'Make program file to read from readmemh'
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
                default='main.dmp',
                help='Set input file name (Default: main.dmp)'
                )

    # Output Filename
    parse.add_argument(
                '-o', 
                '--output',
                type=str,
                action='store',
                default='main.prg',
                help='Set output file name (Default: main.prg)'
                )
    return parse.parse_args()

def ext_inst(in_file):
    data = open(in_file, 'r').read()
    pattern = '.*?([0-9a-f]+):.*?([0-9a-f]{8}).*?'
    return re.findall(pattern, data, re.S)

if __name__ == '__main__' :
    options = parser()
    in_file = options.input
    out_file = options.output

    # extract hex from dump file
    ext_result = ext_inst(in_file)

    # compose instruction list
    inst_list = []
    for line in ext_result:
        pc = line[0].zfill(8)
        inst = line[1]
        inst_line = inst + "\t// " + pc
        inst_list.append(inst_line)

    # output into file
    with open(out_file, 'w') as f:
        f.write("\n".join(inst_list))
