from chevron import render
from toml import load
from sys import argv

def main():
    data_file_path = argv[1]
    og_file_path = argv[2]
    dst_file_path = argv[3]

    data_file = open(data_file_path,'rt')
    og_file = open(og_file_path,'rt')
    dst_file = open(dst_file_path,'wt')

    data = load(data_file)

    result = render(og_file,data,def_ldel='<<',def_rdel='>>')
    dst_file.write(result)

    og_file.close()
    dst_file.close()
    data_file.close()

if __name__ == '__main__':
    main()