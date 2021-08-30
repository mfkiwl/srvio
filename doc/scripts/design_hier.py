#!/usr/bin/env python3
from argparse import ArgumentParser
from pathlib import Path
from copy import deepcopy
import yaml
import sqlite3
# user lib
import yaml_utils
import db_utils

def parser():
    # parser information setup
    prog='design_hier'
    description = 'Construct design hierarchy'
    usage = 'usage: python3 {} ' .format(__file__)
    usage += '[-o outfile]'
    parse = ArgumentParser(
                prog=prog,
                description=description, 
                usage=usage,
                add_help=True
                )

    # Output Filename
    parse.add_argument(
                '-o', 
                '--output',
                type=str,
                action='store',
                default='yaml',
                help='Set output directory (Default: yaml)'
                )

    # Directory structure configuration file
    parse.add_argument(
                '-i', 
                '--input',
                type=str,
                action='store',
                default='design.db',
                help='Set input file database file (Default: design.db)'
                )

    # List of top designs
    parse.add_argument(
                '-t',
                '--top',
                type=str,
                action='store',
                default='top.yml',
                help='Input file list of top design list (Default: top.yml)'
                )
    return parse.parse_args()



def construct_hier(c, mod):
    # Argument
    #   c: sqlite3 cursor
    #   mod: module name
    # Return
    #   Associative array of module dependency

    # Field of read out data from database
    inst_field = 0
    mod_field = 1

    # check directory existence
    #   If table for given module does not exist, the module is leaf.
    #   Then return "." as indicator of the leaf module.
    if not db_utils.check_table(c, mod) :
        return "."

    db_table = db_utils.dump_table(c, mod)
    mod_array = {}

    for sub in db_table :
        sub_inst = sub[inst_field]
        sub_mod = sub[mod_field]
        key = sub_inst + " (" + sub_mod + ")"
        mod_array[key] = construct_hier(c, sub_mod)

    return mod_array



if __name__ == '__main__' :
    # options analysis
    options = parser()
    in_db = options.input
    top_conf_file = options.top
    out_dir = options.output

    # file parse configuration
    top_config = yaml_utils.read_yaml(top_conf_file)

    # Create sqlite3 cursor
    db = sqlite3.connect(in_db)
    c = db.cursor()

    for t in top_config :
        out_file = out_dir + "/" + t + "_hier.yml"
        f = open(out_file, 'w')
        f.write('# Current design is "' + t + '"\n')
        f.close()
        yaml_utils.write_yaml(out_file, construct_hier(c, t), True)
