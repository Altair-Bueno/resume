from json import dump
from sys import argv

from yaml import load, SafeLoader

from model.jsonresume import ResumeSchema
from model.template import TemplateScheme


def main():
    origin_filename = argv[1]
    destination_filename = argv[2]

    with open(origin_filename, "r") as origin:
        d = load(origin, Loader=SafeLoader)

    jsonresume = ResumeSchema(**d)
    data = TemplateScheme.from_jsonresume(jsonresume)

    with open(destination_filename, "w") as destination:
        dump(data.dict(), destination, indent=2)


if __name__ == "__main__":
    main()
