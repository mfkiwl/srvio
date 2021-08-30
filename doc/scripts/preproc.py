#!/usr/bin/env python3
from argparse import ArgumentParser
from pathlib import Path
import yaml
import subprocess
# user lib
import yaml_utils
import file_search

def parser():
    # parser information setup
    prog='preproc'
    description = 'Verilog/SystemVerilog Preprocessor'
    usage = 'usage: python3 {} ' .format(__file__)
    usage += '[-t] [-i] [-o]'
    parse = ArgumentParser(
                prog=prog,
                description=description, 
                usage=usage,
                add_help=True
                )

    # Output Filename
    parse.add_argument(
                '-d', 
                '--dir',
                type=str,
                action='store',
                default='preproc',
                help='Set output directory of preprocessed files(Default: preproc)'
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
                '-s', 
                '--src',
                type=str,
                action='store',
                default='srcdir.yaml',
                help='Set source directory structure configuration (Default: srcdir.yaml)'
                )

    return parse.parse_args()



def v_preproc(file_list, target, inc_list) :
    # Arguments
    #   file_list: list of verilog files to be preprocessed
    #   target: output directory of preprocessed verilog
    #   inc_list: list of directory contains include files

    inc_opt = []
    for dirs in inc_list :
        inc_opt.append('+incdir+' + dirs)

    # preprocess each file in file_list
    for f in file_list :
        path = str(f.absolute())
        out_file_name = target + '/' + f.name
        print('preprocessing ' + path)

        proc_list = []

        try:
            out_file = open(out_file_name, 'w')
            # execute vppreproc (verilog preprocessor)
            #   vppreproc +incdir+X ... +incdir+XXXX design.sv
            cmd = ['vppreproc']
            cmd += inc_opt
            cmd += [path]
            proc_list.append(subprocess.Popen(cmd, stdout=out_file))
        except subprocess.CalledProcessError:
            print('Failed execution of vppreproc', file=sys.stderr)
            sys.exit(1)

    # wait all of subprocess finishes
    for p in proc_list :
        p.wait()



if __name__ == '__main__' :
    # option analysis
    options = parser()
    conf_file = options.config
    src_conf_file = options.src
    inc_conf_file = options.incdir
    out_dir = options.dir

    # file parse configuration
    config = yaml_utils.read_yaml(conf_file)
    src_config = yaml_utils.read_yaml(src_conf_file)
    inc_config = yaml_utils.read_yaml(inc_conf_file)

    # parse files to create source file and include directory list
    top_dir = Path('..').resolve()
    rtl_ext = config['verilog-src'] + config['systemverilog-src']
    file_list = file_search.listup_files(top_dir, rtl_ext, src_config)
    inc_list = file_search.listup_dirs(top_dir, inc_config)

    # Preprocess verilog file. (Remove comment out if you want!)
    v_preproc(file_list, out_dir, inc_list)
