import sys
import subprocess
from pathlib import Path
from copy import deepcopy

def get_files(path, extension) :
    return path.glob('*' + extension)

def tree_construct(path, ext, dir_list) :
    arrays = {}
    keys = dir_list.keys()
    for k in keys :
        dirs = dir_list[k]
        current_dir = Path(str(path) + '/' + k)

        # search for files in current directory
        file_lists = []
        for x in ext :
            #file_lists.extend(current_dir.glob('*' + x))
            file_lists.extend(get_files(current_dir, x))

        if dirs == '.' :
            if len(file_lists) != 0 :
                arrays[k] = sorted(list(map(lambda x: x.name, file_lists)))
        else :
            # parent node
            arrays[k] = tree_construct(current_dir, ext, dirs)
            if len(file_lists) != 0 :
                arrays['_files_'] = sorted(list(map(lambda x: x.name, file_lists)))

    return arrays

def listup_files(path, ext, dir_list) :
    # extensions of target source files
    file_list = []

    keys = dir_list.keys()
    for k in keys :
        dirs = dir_list[k]
        current_dir = Path(str(path) + '/' + k)

        # search for files in current directory
        for x in ext :
            #file_lists.extend(current_dir.glob('*' + x))
            file_list.extend(get_files(current_dir, x))

        if dirs != '.' :
            file_list.extend(listup_files(current_dir, ext, dirs))

    return deepcopy(file_list)

def v_check(file_list, target, inc_conf_file) :
    for f in file_list :
        path = str(f.absolute())
        try:
            print('processing ' + path)
            subprocess.Popen(['perl', './scripts/v_check.pl', '-t', target,
                    '-i', inc_conf_file, '-d', path])
        except subprocess.CalledProcessError:
            print('Failed execution of v_check.pl', file=sys.stderr)
            sys.exit(1)
