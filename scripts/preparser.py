from json import dump

from typer import run
from yaml import load, SafeLoader

from src.model.jsonresume import ResumeSchema
from src.model.template import TemplateScheme


def main(data: str, output: str):
    with open(data, "r") as origin:
        d = load(origin, Loader=SafeLoader)

    jsonresume = ResumeSchema(**d)
    data = TemplateScheme.from_jsonresume(jsonresume)

    with open(output, "w") as destination:
        dump(data.dict(), destination, indent=2)


if __name__ == "__main__":
    run(main)
