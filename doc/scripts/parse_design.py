#!/usr/bin/env python3
from argparse import ArgumentParser
from pathlib import Path
import yaml
import sqlite3
import subprocess
# user lib
import yaml_utils
import file_search
import db_utils

def parser():
    # parser information setup
    prog='parse_design'
    description = 'Parse verilog/systemverilog source files' + \
        'to construct design hierarchy read on database creation'
    usage = 'usage: python3 {} ' .format(__file__)
    usage += '[-o] [-c] [-i] [-d] [-p] [-t]'
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
                default='design.db',
                help='Set output sqlite3 database file name (Default: design.db)'
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



def v_check(file_list, target, inc_conf_file) :
    # Arguments
    #   file_list: list of verilog files to be parsed
    #   target: output directory of yaml
    #   inc_conf_file: yaml file for include directory structures (incdir.yml)

    proc_list = []

    for f in file_list :
        path = str(f.absolute())
        try:
            print('parsing ' + path)
            # Execute perl scripts to extract submodules in each design and output yaml.
            #   perl ./scripts/v_check.pl -t ./yaml/design \
            #       -d design.sv -i ./yaml/incdir.yml
            cmd = ['perl', './scripts/v_check.pl']
            cmd += ['-t', target]
            cmd += ['-i', inc_conf_file]
            cmd += ['-d', path]
            proc_list.append(subprocess.Popen(cmd))
        except subprocess.CalledProcessError:
            print('Failed execution of v_check.pl', file=sys.stderr)
            sys.exit(1)

    # wait all of subprocess finishes
    for p in proc_list :
        p.wait()


if __name__ == '__main__' :
    # options analysis
    options = parser()
    conf_file = options.config
    dir_conf_file = options.dir
    inc_conf_file = options.incdir
    out_file = options.output
    target = options.target

    # file parse configuration
    config = yaml_utils.read_yaml(conf_file)
    dir_config = yaml_utils.read_yaml(dir_conf_file)
    inc_config = yaml_utils.read_yaml(inc_conf_file)

    # parse files to create source file and include directory list
    top_dir = Path('..').resolve()
    rtl_ext = config['verilog-src'] + config['systemverilog-src']
    file_list = file_search.listup_files(top_dir, rtl_ext, dir_config)
    inc_list = file_search.listup_dirs(top_dir, inc_config)

    # Extract submodules in each design
    v_check(file_list, target, inc_conf_file)

    # Register each module and its dependency into sqlite3-based database
    #   table name is named after each module name
    #   table entry has three columns.
    #       mod  : submodule name
    #       inst : instance name of the submodule

    # create sqlite3 cursor
    db = sqlite3.connect(out_file)
    c = db.cursor()

    # create table for each module with submodules
    for f in file_search.get_files(Path(target),".yml") :
        design_name = f.stem
        design_hier = yaml_utils.read_yaml(str(f.absolute()))

        # Do not create table for leaf modules
        if len(design_hier) == 0 :
            continue

        keys = 'inst varchar(32), '
        keys += 'mod varchar(32)'
        if not db_utils.check_table(c, design_name) :
            print("Newly create table: " + design_name)
            db_utils.create_table(c, design_name, keys)

        for sub_inst in design_hier.keys() :
            sub_mod = design_hier[sub_inst]

            # if given sub_inst does not exist in table
            if not db_utils.check_db(c, design_name, "inst", sub_inst) :
                keys = 'mod, inst'
                values = '\'' + sub_mod + '\', '
                values += '\'' + sub_inst + '\''
                db_utils.register_db(c, design_name, keys, values)

    # end database operation
    db.commit()
    db.close()
