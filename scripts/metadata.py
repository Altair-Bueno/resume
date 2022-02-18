from toml import load
from json import dump
from sys import argv

def main():
    data_file = open(argv[1],'rt')
    output_file = open(argv[2],'wt')

    data = load(data_file)
    dump(data['pandoc'],output_file)

    data_file.close()
    output_file.close()

if __name__ == '__main__':
    main()