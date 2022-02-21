from datetime import datetime
from dateutil.parser import parse
from toml import load,dump
from sys import argv

__DEFAULT_VALUES = {
    'fontsize': '10pt',
    'fontenc':'T1',
    'urlcolor':'blue',
    'linkcolor':'magenta',
}

def sort_key(element) -> datetime:
    if not isinstance(element,dict):
        return datetime.max

    result = None
    if 'date' in element:
        result = element['date']
    elif 'from' in element:
        result = element['from']
    else:
        result = ''
    
    try: return parse(result)
    except: return datetime.max

def sort_by_date(data):
    if isinstance(data,list):
        data.sort(reverse=True,key=sort_key)
    elif isinstance(data,dict):
        for value in data.values():
            sort_by_date(value)

def set_default_values(data:dict):
    data = __DEFAULT_VALUES | data
    if 'skills' not in data: data['skills'] = {}
    if 'cols' not in data['skills']: data['skills']['cols'] = 6

def prepare_data(data):
    set_default_values(data)
    sort_by_date(data)
    return  data

def main():
    og_file = open(argv[1],'rt')
    dst_file = open(argv[2],'wt')

    data = load(og_file)
    data = prepare_data(data)
    dump(data,dst_file)

    og_file.close()
    dst_file.close()

if __name__ == '__main__':
    main()