from datetime import date
from dateutil.parser import parse
from toml import load,dump
from sys import argv

__DEFAULT_VALUES = {
    'date':str(date.today()),
    'fontsize': '10pt',
    'fontenc':'T1',
    'urlcolor':'blue',
    'linkcolor':'magenta',
}

def set_default_values(data)-> dict:
    return __DEFAULT_VALUES | data

def modify_data(data):
    data = set_default_values(data)
    return  data

def main():
    og_file = open(argv[1],'rt')
    dst_file = open(argv[2],'wt')

    data = load(og_file)
    data = modify_data(data)
    dump(data,dst_file)

    og_file.close()
    dst_file.close()

if __name__ == '__main__':
    main()