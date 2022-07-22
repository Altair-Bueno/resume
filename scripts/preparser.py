from json import dump
from sys import argv

from yaml import load, SafeLoader

from model.jsonresume import ResumeSchema
from model.template import TemplateScheme


def main():
    with open(argv[1], "r") as origin, open(argv[2], "w") as destination:
        jsonresume = ResumeSchema(**load(origin, Loader=SafeLoader))
        data = TemplateScheme.from_jsonresume(jsonresume)
        dump(data.dict(), destination, indent=2)


if __name__ == "__main__":
    main()
