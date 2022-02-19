from datetime import date
from dateutil.parser import parse
from toml import load,dump
from sys import argv

def set_default_values(data)-> dict:
    if data['pandoc'] == None: data['pandoc'] = {}
    data['pandoc']['date'] = str(date.today())


    return data

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