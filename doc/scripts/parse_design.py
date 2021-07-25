#!/usr/bin/env python3
from argparse import ArgumentParser
import yaml
from pathlib import Path
import yaml_utils
import file_search
import subprocess

def parser():
    # parser information setup
    prog='parse_design'
    description = 'Parse verilog/systemverilog source files' + \
        'to construct design hierarchy read on database creation'
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
                default='parse_design.yaml',
                help='Set output yaml file name (Default: parse_design.yaml)'
                )

    # Directory parsing configuration file
    parse.add_argument(
                '-c', 
                '--config',
                type=str,
                action='store',
                default='config.yaml',
                help='Set directory parsing configuration (Default: config.yaml)'
                )

    # Directory structure configuration file
    parse.add_argument(
                '-i', 
                '--incdir',
                type=str,
                action='store',
                default='incdir.yaml',
                help='Set include directory structure configuration (Default: incdir.yaml)'
                )

    # Directory structure configuration file
    parse.add_argument(
                '-d', 
                '--dir',
                type=str,
                action='store',
                default='dir.yaml',
                help='Set directory structure configuration (Default: dir.yaml)'
                )

    # Dump target directory of module dependency files (yaml)
    parse.add_argument(
                '-t',
                '--target',
                type=str,
                action='store',
                default='design',
                help='Set target directory to output module dependency yaml files (Default:design)'
                )
    return parse.parse_args()

if __name__ == '__main__' :
    # options analysis
    options = parser()
    conf_file = options.config
    dir_conf_file = options.dir
    inc_conf_file = options.incdir
    outfile = options.output
    target = options.target

    # file parse configuration
    config = yaml_utils.read_yaml(conf_file)
    dir_config = yaml_utils.read_yaml(dir_conf_file)

    # parse files to create source file list
    top_dir = Path('..').resolve()
    rtl_ext = config['verilog-src'] + config['systemverilog-src']
    file_list = file_search.listup_files(top_dir, rtl_ext, dir_config)

    # interpret each source file and resolve module dependency
    file_search.v_check(file_list, target, inc_conf_file)
