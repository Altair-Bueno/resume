from datetime import datetime
from functools import reduce
from json import dump
from sys import argv

from dateutil.parser import parse, ParserError
from toml import load


def sorter_extract_key(element: dict):
    """Extracts the key that sorter requires"""
    if 'date' in element:
        result = element['date']
    elif 'from' in element:
        result = element['from']
    else:
        result = ''

    try:
        return parse(result)
    except ParserError:
        return datetime.max


def sorter(elements: list[dict]):
    """Sorts the lists content"""
    if not isinstance(elements, list):
        return elements

    elements.sort(key=sorter_extract_key, reverse=True)
    return elements


def reduce_strategy(acc: dict, next):
    k, v = next

    if k in acc:
        acc[k] = lambda x: acc[k](v(x))
    else:
        acc[k] = v

    return acc


def merge_strategies(strategy: dict, extension: dict):
    """Merges two strategies together

    a = { "foo": foo }
    b = { "foo": baz }
    merge_strategies(a,b) # { "foo": lambda x: baz(foo(x)) }
    """
    return reduce(reduce_strategy, extension.items(), strategy.copy())


def transform(values, strategy, default_values):
    if values is None or strategy is None or default_values is None:
        return None

    result = default_values | values

    for k, f in strategy.items():
        result[k] = f(result.get(k))

    return result


def main():
    original_path = argv[1]
    destination_path = argv[2]
    with open(original_path, 'r') as original, \
            open(destination_path, 'w') as destination:
        # TOML to JSON with type `Resume`
        raw_resume = load(original)
        resume = transform(raw_resume, RESUME_STRATEGY, RESUME_DEFAULT_VALUES)
        dump(resume, destination)


GENERIC_STRATEGY = {
    "list": sorter
}

RESUME_STRATEGY = merge_strategies(GENERIC_STRATEGY, {
    "column": lambda x: transform(x, COLUMN_STRATEGY, COLUMN_DEFAULT_VALUES),
    "summary": lambda x: transform(x, SUMMARY_STRATEGY, SUMMARY_DEFAULT_VALUES),
    "skills": lambda x: transform(x, SKILLS_STRATEGY, SKILLS_DEFAULT_VALUES),
    "experience": lambda x: transform(x, EXPERIENCE_STRATEGY,
                                      EXPERIENCE_DEFAULT_VALUES),
    "education": lambda x: transform(x, EDUCATION_STRATEGY, EDUCATION_STRATEGY),
    "formation": lambda x: transform(x, FORMATION_STRATEGY,
                                     FORMATION_DEFAULT_VALUES),
    "github": lambda x: transform(x, GITHUB_STRATEGY, GITHUB_DEFAULT_VALUES),
    "other": lambda x: transform(x, OTHER_STRATEGY, OTHER_DEFAULT_VALUES)
})

COLUMN_STRATEGY = merge_strategies(GENERIC_STRATEGY, {})
OTHER_STRATEGY = merge_strategies(GENERIC_STRATEGY, {})
GITHUB_STRATEGY = merge_strategies(GENERIC_STRATEGY, {})
EDUCATION_STRATEGY = merge_strategies(GENERIC_STRATEGY, {})
FORMATION_STRATEGY = merge_strategies(GENERIC_STRATEGY, {})
SKILLS_STRATEGY = merge_strategies(GENERIC_STRATEGY, {})
SUMMARY_STRATEGY = merge_strategies(GENERIC_STRATEGY, {})
EXPERIENCE_STRATEGY = merge_strategies(GENERIC_STRATEGY, {})

RESUME_DEFAULT_VALUES = {
    'fontsize': '10pt',
    'fontenc': 'T1',
    'urlcolor': 'blue',
    'linkcolor': 'magenta'
}
COLUMN_DEFAULT_VALUES = {}
OTHER_DEFAULT_VALUES = {}
GITHUB_DEFAULT_VALUES = {}
FORMATION_DEFAULT_VALUES = {}
EDUCATION_DEFAULT_VALUES = {}
EXPERIENCE_DEFAULT_VALUES = {}
SKILLS_DEFAULT_VALUES = {"cols": 6}
SUMMARY_DEFAULT_VALUES = {}

if __name__ == '__main__':
    main()
