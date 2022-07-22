from __future__ import annotations

from itertools import chain
from typing import List
from urllib.parse import urlparse

import phonenumbers
from glom import glom
from iso3166 import countries

from ..model import template
from ..model.jsonresume import ResumeSchema


def label_column(data: ResumeSchema) -> template.Column:
    """Generates a Column using `basics.label`"""
    title = data.basics.label
    return template.Column(title=title)


def mail_column(data: ResumeSchema) -> template.Column:
    """Generates a Column using `basics.email`

    Example
    =======

    **Software Developer**

    More information
    ================

    - RFC6068: https://datatracker.ietf.org/doc/html/rfc6068
    """
    email = data.basics.email
    email_link = template.Link(to=f"mailto:{email}", content=email)
    return template.Column(title="Email", link=email_link)


def phone_column(data: ResumeSchema):
    """Generates a Column using `basics.phone`

    Example
    =======

    **Phone**: [+11 1111](tel:+111111)

    More information
    ================

    - RFC3966: https://datatracker.ietf.org/doc/html/rfc3966
    """
    phone = phonenumbers.parse(data.basics.phone, None)
    phone_content = phonenumbers.format_number(
        phone, phonenumbers.PhoneNumberFormat.INTERNATIONAL
    )
    phone_to = phonenumbers.format_number(phone, phonenumbers.PhoneNumberFormat.E164)
    phone_to = f"tel:{phone_to}"
    phone_link = template.Link(to=phone_to, content=phone_content)
    return template.Column(title="Phone", link=phone_link)


def location_column(data: ResumeSchema):
    """Generates a Column using `basics.location`

    Example
    =======

    **Location**: Madrid, Spain
    """
    location = data.basics.location
    country = countries.get(location.countryCode)
    content = f"{location.region}, {country.name}"
    return template.Column(title="Location", content=content)


def website_column(data: ResumeSchema):
    """Generates a Colum using `basics.url`.

    Example
    =======

    **Website**: [example.org](https://example.org)
    """
    website = data.basics.url
    website_content = urlparse(website).netloc
    website_link = template.Link(to=website, content=website_content)
    return template.Column(title="Website", link=website_link)


def keywords(data: ResumeSchema) -> List[str]:
    """Extracts keywords from:

    - `meta.keywords`
    - `work._.name`
    - `work._.position`
    - `education._.institution`
    - `education._.area`
    - `skills._.name`
    - `skills._.keywords`
    - `projects._.keywords`
    """
    meta = glom(data, "meta.keywords", default=[])

    work = data.work or []
    work = map(lambda x: (x.name, x.position), work)
    work = chain.from_iterable(work)

    education = data.education or []
    education = map(lambda x: (x.institution, x.area), education)
    education = chain.from_iterable(education)

    skills = data.skills or []
    skills = map(lambda x: [x.name] + (x.keywords or []), skills)
    skills = chain.from_iterable(skills)

    projects = data.projects or []
    projects = map(lambda x: x.keywords, projects)
    projects = filter(None, projects)
    projects = chain.from_iterable(projects)

    res = chain(meta, work, education, skills, projects)
    res = filter(None, res)
    res = list(set(res))

    return res
