from __future__ import annotations

from datetime import date
from itertools import chain
from typing import List, Optional, TypeVar, Generic
from urllib.parse import urlparse

import phonenumbers
from glom import glom
from pydantic import BaseModel, root_validator
from pydantic.generics import GenericModel

from .jsonresume import EducationItem
from .jsonresume import Project as ProjectItem
from .jsonresume import ResumeSchema, WorkItem

Content = TypeVar("Content")


def extract_keywords(jsonresume: ResumeSchema):
    # TODO extract keywords
    meta = glom(jsonresume, "meta.keywords", default=[])

    work = jsonresume.work or []
    work = map(lambda x: (x.name, x.position), work)
    work = chain.from_iterable(work)

    return set(chain(meta, work))


def sort_by_date(elements: List[Content]) -> List[Content]:
    def get_key(x):
        if "date" in x:
            out = x.date
        elif "endDate" in x:
            out = x.endDate
        else:
            out = None
        return out or date.today()

    return sorted(elements, key=get_key, reverse=True)


class Link(BaseModel):
    """
    Represents a LaTeX \\href

    Attributes:

    - to: Where should the link point to
    - content (optional): Linked text
    """

    to: str
    content: Optional[str]


class Date(BaseModel):
    """
    Represents a time period. Invalid dates such as `Present` or `Current` are
    allowed for the end attribute

    Attributes

    - start: Start of the period
    - end: End of the period
    """

    start: str
    end: str = "Current"


class Column(BaseModel):
    """
    Represents an entry on an information column

    Attributes

    - title: Bold text
    """

    title: str
    link: Optional[Link]
    content: Optional[str]


class Experience(BaseModel):
    """Represents an individual job"""

    company: str
    role: str
    summary: str
    highlights: List[str]
    date: Date


class Education(BaseModel):
    """Represents education received"""

    title: str
    summary: Optional[str]
    institution: Optional[str]
    date: Optional[str]


class Qualification(BaseModel):
    """"""

    title: str
    date: Optional[str]
    link: Optional[Link]


class Project(BaseModel):
    title: str
    summary: str
    link: Optional[Link]


class Other(BaseModel):
    title: str
    summary: Optional[str]


class GenericSection(GenericModel, Generic[Content]):
    title: str
    list: List[Content]


class OtherSection(GenericSection[Other]):
    @classmethod
    def from_jsonresume(cls, jsonresume: ResumeSchema) -> Optional[OtherSection]:
        def inner(x):  # TODO not ready
            return Other(title="Not implemented", summary="Not implemented")

        def volunteer():
            return (
                [inner(x) for x in jsonresume.volunteer] if jsonresume.volunteer else []
            )

        def awards():
            return [inner(x) for x in jsonresume.awards] if jsonresume.awards else []

        def publications():
            return (
                [inner(x) for x in jsonresume.publications]
                if jsonresume.publications
                else []
            )

        def interests():
            return (
                [inner(x) for x in jsonresume.interests] if jsonresume.interests else []
            )

        elements = volunteer() + awards() + publications() + interests()

        if elements:
            return OtherSection(title="Other", list=elements)
        else:
            return None


class ProjectSection(GenericSection[Project]):
    @classmethod
    def from_jsonresume(cls, jsonresume: ResumeSchema) -> Optional[ProjectSection]:
        if not jsonresume.projects:
            return None

        def inner(project: ProjectItem) -> Project:
            summary = project.description
            content = urlparse(project.url).path.strip("/")
            link = Link(to=project.url, content=content)
            return Project(title=project.name, link=link, summary=summary)

        projects = [inner(p) for p in jsonresume.projects]
        return ProjectSection(title="Projects", list=projects)


class QualificationSection(GenericSection[Qualification]):
    @classmethod
    def from_jsonresume(cls, jsonresume: ResumeSchema) -> Optional[QualificationSection]:
        if not jsonresume.certificates:
            return None

        def inner(f):
            print(f.url,f.issuer)
            return Qualification(
                title=f.name, date=f.date, link=Link(to=f.url, text=f.issuer)
            )

        formation = [inner(f) for f in sort_by_date(jsonresume.certificates)]
        return QualificationSection(title="Qualifications", list=formation)


class EducationSection(GenericSection[Education]):
    @classmethod
    def from_jsonresume(cls, jsonresume: ResumeSchema) -> Optional[EducationSection]:
        if not jsonresume.education:
            return None

        def inner(education: EducationItem) -> Education:
            if education.endDate:
                date = education.endDate.year
            else:
                date = None
            return Education(
                title=f"{education.area}, {education.studyType}",
                institution=education.institution,
                summary=education.score,
                date=date,
            )

        education = [inner(e) for e in sort_by_date(jsonresume.education)]
        return EducationSection(title="Education", list=education)


class ExperienceSection(GenericSection[Experience]):
    @classmethod
    def from_jsonresume(cls, jsonresume: ResumeSchema) -> Optional[ExperienceSection]:
        if not jsonresume.work:
            return None

        def inner(work: WorkItem) -> Experience:
            start_date = work.startDate.year
            end_date = work.endDate.year

            # If both dates have the same year, only show the year once
            # Eg: `2018-2018` vs `2018`
            if start_date == end_date:
                end_date = None

            return Experience(
                company=work.name,
                role=work.position,
                summary=work.summary,
                highlights=work.highlights,
                date=Date(start=start_date, end=end_date),
            )

        experience = [inner(e) for e in sort_by_date(jsonresume.work)]
        return ExperienceSection(title="Experience", list=experience)


class SkillSection(GenericSection[str]):
    cols: int = 6

    @classmethod
    def from_jsonresume(cls, jsonresume: ResumeSchema) -> Optional[SkillSection]:
        if jsonresume.skills is None:
            return None

        skills = [s.name for s in jsonresume.skills]
        return SkillSection(title="Skills", list=skills)


class SummarySection(BaseModel):
    title: str
    content: str

    @classmethod
    def from_jsonresume(cls, jsonresume: ResumeSchema) -> SummarySection:
        return SummarySection(title="Summary", content=jsonresume.basics.summary)


class ColumnSection(BaseModel):
    left: List[Column]
    right: List[Column]

    @classmethod
    def from_jsonresume(cls, jsonresume: ResumeSchema) -> ColumnSection:
        def mail_col():
            email = jsonresume.basics.email
            email_link = Link(to=f"mailto:{email}", content=email)
            return Column(title="Email", link=email_link)

        def phone_col():
            phone = phonenumbers.parse(jsonresume.basics.phone, None)
            phone_content = phonenumbers.format_number(
                phone, phonenumbers.PhoneNumberFormat.INTERNATIONAL
            )
            phone_to = phonenumbers.format_number(
                phone, phonenumbers.PhoneNumberFormat.E164
            )
            phone_to = f"tel:{phone_to}"
            phone_link = Link(to=phone_to, content=phone_content)
            return Column(title="Phone", link=phone_link)

        def website_col():
            website = jsonresume.basics.url
            website_content = urlparse(website).netloc
            website_link = Link(to=website, content=website_content)
            return Column(title="Website", link=website_link)

        def profiles_cols():
            return [
                Column(title=p.network, link=Link(to=p.url, content=p.username))
                for p in jsonresume.basics.profiles
            ]

        columns = [
            Column(title=jsonresume.basics.label),
            mail_col(),
            phone_col(),
            website_col(),
        ] + profiles_cols()
        middle = len(columns) // 2
        return ColumnSection(left=columns[:middle], right=columns[middle:])


class TemplateScheme(BaseModel):
    """
    Represents all posible
    """

    mainfont: str
    title: str
    subject: str = "Resume"
    name: str
    keywords: List[str]
    fontsize = "10pt"
    fontenc = "T1"
    urlcolor = "blue"
    linkcolor = "magenta"
    numbersections = False
    ruler = False
    column: Optional[ColumnSection]
    summary: Optional[SummarySection]
    skills: Optional[SkillSection]
    experience: Optional[ExperienceSection]
    education: Optional[EducationSection]
    formation: Optional[QualificationSection]
    project: Optional[ProjectSection]
    other: Optional[OtherSection]

    @root_validator(pre=True)
    def __remove_nones__(cls, values):
        # Remove None values received that might interfere with defaults values
        return {k: v for k, v in values.items() if v is not None}

    @classmethod
    def from_jsonresume(cls, jsonresume: ResumeSchema) -> TemplateScheme:
        extract = lambda x: glom(jsonresume, x, default=None)

        return TemplateScheme(
            mainfont=extract("meta.latex.mainfont"),
            title=extract("meta.title"),
            name=extract("basics.name"),
            keywords=extract_keywords(jsonresume),
            fontsize=extract("meta.latex.fontsize"),
            fontenc=extract("meta.latex.fontenc"),
            urlcolor=extract("meta.latex.urlcolor"),
            linkcolor=extract("meta.latex.linkcolor"),
            numbersections=extract("meta.latex.numbersections"),
            ruler=extract("meta.latex.ruler"),
            column=ColumnSection.from_jsonresume(jsonresume),
            summary=SummarySection.from_jsonresume(jsonresume),
            skills=SkillSection.from_jsonresume(jsonresume),
            experience=ExperienceSection.from_jsonresume(jsonresume),
            education=EducationSection.from_jsonresume(jsonresume),
            formation=QualificationSection.from_jsonresume(jsonresume),
            project=ProjectSection.from_jsonresume(jsonresume),
            other=OtherSection.from_jsonresume(jsonresume),
        )
