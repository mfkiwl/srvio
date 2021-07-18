#!/usr/bin/python3

import os
import sys
from argparse import ArgumentParser

# parse argument
def parser():
    # parser information setup
    prog='mk_template'
    description = 'Make test file template from top level Verilog'
    usage = 'usage: python3 {} ' .format(__file__)
    usage += '[-I <include directory>] '
    usage += '[-D <define>] '
    usage += 'TOP_MODULE'
    parse = ArgumentParser(
                prog=prog,
                description=description, 
                usage=usage,
                add_help=True
                )

    # Include directory setup
    parse.add_argument(
                'top',
                type=str,
                help='Top Module'
                )
    parse.add_argument(
                '-I', 
                '--incdir',
                type=str,
                action='append',
                help='Set Include Directory'
                )

    # Include directory setup
    parse.add_argument(
                '-D', 
                '--define',
                type=str,
                action='append',
                help='Set Define'
                )

    # Define setup
    return parse.parse_args()

if __name__ == "__main__" :
    options = parser()
    print(options)
