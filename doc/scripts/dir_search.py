from pathlib import Path
from copy import deepcopy

# get absolute path
def get_absolute(path):
    return path.resolve()



# parse directory
# Argument
#   path: path object
#   ext: extension to be searched (list of str)
#   skip: directory to be skipped (list of str)
#   list_files: list up files that matches extension in 'ext' (Legacy, do not use)
# Return
#   list of Path instances
def dir_parse(path, ext, list_files, skip):
    add_dir = False
    is_parent = False
    path_list = []
    file_list = []

    # Ignore directories in skip list
    for s in skip :
        if s in path.name :
            return []

    # Search for directories containing files with extenstions listed in 'ext'
    for p in path.iterdir() :
        if ( p.is_dir() ) :
            ret_list = dir_parse(p, ext, list_files, skip)
            if len(ret_list) != 0 :
                path_list.append(ret_list)
        else :
            if p.suffix in ext :
                add_dir = True

                # if file listing mode, save 'p' to list
                if list_files :
                    file_list.append(p)

    if add_dir and list_files :
        path_list.append(file_list)

    # add parent node or leaf containing target files
    if add_dir or len(path_list) != 0 :
        path_list.append(path)

    return deepcopy(path_list)



# create directory hierarchy
# Argument :
#   dir_list : subset of parent directory's pathlib list
# Return
#   List of mixture of directory names and associative arrays of directories
def create_dir_hier(dir_list):
    arrays = {}
    for x in dir_list:
        dir_name = x[-1].name
        if len(x) == 1 :
            # used as directory search termination symbol
            arrays[dir_name] = '.'
        else :
            arrays[dir_name] = create_dir_hier(x[:-1])

    return deepcopy(arrays)



# analyze and compose list
# Argument :
#   dir_list: list of pathlib object
# Return
#   top_dir: absolute path of top-level directory
#   arrays: associative list of directories
def dir_analyze(dir_list, list_files) :
    # get absolute path of top level directory
    top_dir = get_absolute(dir_list[-1])
    top_dir_name = str(top_dir)
    # sub array except for the last element (= top level directory)
    sub_dirs = dir_list[:-1]
    # associative arrays to write into yaml
    arrays = {}

    if list_files : 
        # file listing mode
        arrays[top_dir] = create_file_hier(sub_dirs)
    else :
        # directory listing mode
        arrays[top_dir] = create_dir_hier(sub_dirs)

    return top_dir, deepcopy(arrays[top_dir])
