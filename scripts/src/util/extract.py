from itertools import chain
from typing import List
from urllib.parse import urlparse

import phonenumbers
from glom import glom
from iso3166 import countries

from ..model import jsonresume
from ..model import template


def label_column(data: jsonresume.ResumeSchema):
    title = data.basics.label
    return template.Column(title=title)


def mail_column(data: jsonresume.ResumeSchema):
    email = data.basics.email
    email_link = template.Link(to=f"mailto:{email}", content=email)
    return template.Column(title="Email", link=email_link)


def phone_column(data: jsonresume.ResumeSchema):
    phone = phonenumbers.parse(data.basics.phone, None)
    phone_content = phonenumbers.format_number(
        phone, phonenumbers.PhoneNumberFormat.INTERNATIONAL
    )
    phone_to = phonenumbers.format_number(phone, phonenumbers.PhoneNumberFormat.E164)
    phone_to = f"tel:{phone_to}"
    phone_link = template.Link(to=phone_to, content=phone_content)
    return template.Column(title="Phone", link=phone_link)


def location_column(data: jsonresume.ResumeSchema):
    location = data.basics.location
    country = countries.get(location.countryCode)
    content = f"{location.region}, {country.name}"
    return template.Column(title="Location", content=content)


def website_column(data: jsonresume.ResumeSchema):
    website = data.basics.url
    website_content = urlparse(website).netloc
    website_link = template.Link(to=website, content=website_content)
    return template.Column(title="Website", link=website_link)


def keywords(data: jsonresume.ResumeSchema) -> List[str]:
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
