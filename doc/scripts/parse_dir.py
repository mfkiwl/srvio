#!/usr/bin/env python3
from argparse import ArgumentParser
import yaml
from pathlib import Path
import dir_search
import yaml_utils

def parser():
    # parser information setup
    prog='parse_dir'
    description = 'Parse directories ' + \
        'to create yaml file read on database creation'
    usage = 'usage: python3 {} ' .format(__file__)
    usage += '[-t target(dir or design_hier)][-o outfile]'
    parse = ArgumentParser(
                prog=prog,
                description=description, 
                usage=usage,
                add_help=True
                )

    # Target Flow
    parse.add_argument(
                '-t', 
                '--target',
                type=str,
                action='store',
                required=True,
                help='target yaml configuration file (dir, design_hier, incdir, srcdir)'
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

    # Output Filename
    parse.add_argument(
                '-o', 
                '--output',
                type=str,
                action='store',
                default='main.yaml',
                help='Set output yaml file name (Default: main.yaml)'
                )
    return parse.parse_args()



if __name__ == '__main__' :
    options = parser()
    conf_file = options.config
    target = options.target
    out_file = options.output

    # directory parse configutaion
    config = yaml_utils.read_yaml(conf_file)
    rtl_ext = config['verilog'] + config['systemverilog']
    src_ext = config['verilog-src'] + config['systemverilog-src']
    inc_ext = config['verilog-header'] + config['systemverilog-header']
    skip = config['skip']

    # path instance
    path = Path('..')

    # process switch
    list_files = False
    if target == "dir" :
        print("Directory structure analysis mode")
        search_ext = rtl_ext
    elif target == "incdir" :
        print("Include directory search mode")
        search_ext = inc_ext
    elif target == "srcdir" :
        print("Source directory search mode")
        search_ext = src_ext
    elif target == "files" :
        print("Source files search mode")
        search_ext = rtl_ext
        list_files = True
    else :
        print("invalid target mode: " + target)


    # search directory
    dir_list = dir_search.dir_parse(path, search_ext, list_files, skip)
    top_dir, conf_list = dir_search.dir_analyze(dir_list, list_files)

    # dump output
    print('Output yaml: ' + out_file)
    with open(out_file, 'w') as outf:
        outf.write('# Top Directory: ' + str(top_dir) + '\n')
        yaml.dump(conf_list, outf)
