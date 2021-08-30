import sys
from pathlib import Path
from copy import deepcopy

def get_files(path, extension) :
    return path.glob('*' + extension)

def tree_construct(path, ext, dir_array) :
    # Arguments
    #   path: top directory from which directory search starts
    #   ext: file extention of search target
    #   dir_array: associative array read from yaml file
    #               such as incdir.yaml and srcdir.yml
    # Return
    #   list of absolute path of files

    arrays = {}
    keys = dir_array.keys()
    for k in keys :
        dirs = dir_array[k]
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

def listup_dirs(path, dir_array) :
    # Arguments
    #   path: top directory from which directory search starts
    #   dir_array: associative array read from yaml file
    #               such as incdir.yaml and srcdir.yml
    # Return
    #   list of absolute path of directories

    dir_list = []
    keys = dir_array.keys()
    for k in keys :
        dirs = dir_array[k]
        current_dir = Path(str(path) + '/' + k)

        if dirs == '.' :
            # if leaf directory, append its absolute path to list
            dir_list.append(str(current_dir.resolve()))
        else :
            # if not leaf directory, further go down hierarchy
            dir_list.extend(listup_dirs(current_dir, dirs))

    return deepcopy(dir_list)

def listup_files(path, ext, dir_array) :
    # Arguments
    #   path: top directory from which directory search starts
    #   ext: file extention of search target
    #   dir_array: associative array read from yaml file
    #               such as incdir.yaml and srcdir.yml
    # Return
    #   list of absolute path of files

    # extensions of target source files
    file_list = []

    keys = dir_array.keys()
    for k in keys :
        dirs = dir_array[k]
        current_dir = Path(str(path) + '/' + k)

        # search for files in current directory
        for x in ext :
            #file_lists.extend(current_dir.glob('*' + x))
            file_list.extend(get_files(current_dir, x))

        if dirs != '.' :
            file_list.extend(listup_files(current_dir, ext, dirs))

    return deepcopy(file_list)
