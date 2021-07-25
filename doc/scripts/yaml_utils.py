#!/usr/bin/env python3

import yaml

def read_yaml(in_file):
    f = open(in_file, 'r')
    return yaml.load(f, Loader=yaml.SafeLoader)

def write_yaml(out_file, yaml_list):
    with open(out_file, 'w') as outf:
        yaml.dump(yaml_list, outf, Dumper=ListIndentDumper)

class ListIndentDumper(yaml.Dumper):
    def increase_indent(self, flow=False, indentless=False):
        return super(ListIndentDumper, self).increase_indent(flow, False)
