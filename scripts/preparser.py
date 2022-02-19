from dateutil.parser import parse
from toml import load,dump
from sys import argv

__DEFAULT_VALUES = {
    'fontsize': '10pt',
    'fontenc':'T1',
    'urlcolor':'blue',
    'linkcolor':'magenta',
}

def sort_key(element) -> str:
    if not isinstance(element,dict):
        return parse('1999-01-01')

    if 'date' in element:
        return parse(element['date'])
    elif 'from' in element:
        return parse(element['from'])
    else:
        return parse('1999-01-01')

def sort_by_date(data):
    if isinstance(data,list):
        data.sort(reverse=True,key=sort_key)
    elif isinstance(data,dict):
        for key in data.keys():
            sort_by_date(data[key])
def set_default_values(data:dict):
    data = __DEFAULT_VALUES | data
    if 'skills' not in data: data['skills'] = {}
    if 'cols' not in data['skills']: data['skills']['cols'] = 6

def modify_data(data):
    set_default_values(data)
    sort_by_date(data)
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