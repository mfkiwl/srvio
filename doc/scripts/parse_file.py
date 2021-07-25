#!/usr/bin/env python3
from argparse import ArgumentParser
import yaml
from pathlib import Path
import yaml_utils
import file_search

def parser():
    # parser information setup
    prog='parse_file'
    description = 'Parse files' + \
        'to create yaml file read on database creation'
    usage = 'usage: python3 {} ' .format(__file__)
    usage += '[-o outfile]'
    parse = ArgumentParser(
                prog=prog,
                description=description, 
                usage=usage,
                add_help=True
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
                '-d', 
                '--dir',
                type=str,
                action='store',
                default='config.yaml',
                help='Set directory structure configuration (Default: dir.yaml)'
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
    dir_conf_file = options.dir
    outfile = options.output
    
    # file parse configuration
    config = yaml_utils.read_yaml(conf_file)
    dir_config = yaml_utils.read_yaml(dir_conf_file)
    rtl_ext = config['verilog'] + config['systemverilog']
    skip = config['skip']

    # path instance
    top_dir = Path('..').resolve()

    # construct directory tree
    file_tree = file_search.tree_construct(top_dir, rtl_ext, dir_config)

    # dump output
    print('Output yaml: ' + outfile)
    with open(outfile, 'w') as outf:
        outf.write('# Top Directory: ' + str(top_dir) + '\n')
        yaml.dump(file_tree, outf, Dumper=yaml_utils.ListIndentDumper)
