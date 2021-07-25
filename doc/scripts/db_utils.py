#!/usr/bin/python3
import sqlite3
import sys

# check existence of certain table
def check_table(c, table_name) :
    # Argument
    #   c: sqlite3 cursor
    #   table_name: table name of search target
    # Return
    #   True: target table exists in the database
    #   False: target table does not exist in the database
    c.execute("SELECT * FROM sqlite_master where type = 'table' " +
            'and name = \'' + table_name + '\'')
    if c.fetchone() :
        return True
    else :
        return False


# create new table
def create_table(c, table_name, keys) :
    # Argument
    #   c: sqlite3 cursor
    #   table_name: name of newly created table
    #   keys: columns of newly created database
    #       If the database has id (int) and name (varchar(32)),
    #       keys will be 'id int, name varchar(32)'
    # Return
    #   True: Successfully created a new table
    #   False: Target table is already existed
    if ( check_table(c, table_name) ) :
        print('The table \'' + table_name + '\' already exists', file=sys.stderr)
        return False
    else :
        c.execute('CREATE TABLE ' + table_name + '(' + keys + ')')
        return True


# search for entry where entry[key] == value
def check_db(c, table_name, key, value) :
    # Argument
    #   c: sqlite3 cursor
    #   table_name: name of newly created table
    #   key: one of the keys of the search target
    #   value: value of the target
    # Return
    #   True: Target found
    #   False: Target not found
    c.execute('SELECT * FROM ' + table_name + 
            ' where ' + key + '=\"' + value + '\"')
    if c.fetchone() :
        return True
    else :
        return False


# register new entry into table
def register_db(c, table_name, keys, values) :
    # Argument
    #   c: sqlite3 cursor
    #   table_name: name of newly created table
    #   keys: colums of the newly created entry
    #       If you add entry with id (int) and name (varchar(32)),
    #       keys will be 'id, name'
    #   values: value of the entry
    #       If you add entry with id = 1 and name = abcd,
    #       values will be '1, \'abcd\'' 
    #       (escape with \ is necessary for string value)
    command = 'INSERT INTO ' + table_name + '(' + keys + ') '
    command += 'values(' + values + ')'
    c.execute(command)
