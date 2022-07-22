from __future__ import annotations

from datetime import date
from itertools import chain
from math import ceil
from typing import Optional, TypeVar, Generic, List
from urllib.parse import urlparse

from glom import glom
from pydantic import BaseModel, root_validator
from pydantic.generics import GenericModel

from .jsonresume import EducationItem, Certificate
from .jsonresume import Project as ProjectItem
from .jsonresume import ResumeSchema, WorkItem
from ..util import extract
from ..util.other import from_award, from_publication

Content = TypeVar("Content")


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
    """Represents a LaTeX \\href

    Attributes
    ==========

    - to: Where should the link point to
    - content: Linked text
    """

    to: str
    content: str


class Date(BaseModel):
    """Represents a date. If the end date is `None`, only the start date will be shown

    Attributes
    ==========

    - start: Start of the period
    - end: End of the period
    """

    start: str
    end: Optional[str]


class Column(BaseModel):
    """Represents an entry on an information column for the Column Section"""

    title: str
    content: Optional[str]
    link: Optional[Link]


class Experience(BaseModel):
    """Represents an individual job on the Experience section"""

    company: str
    role: str
    summary: str
    highlights: List[str]
    date: Date


class Education(BaseModel):
    """Represents education received on the Education Section"""

    title: str
    summary: Optional[str]
    institution: Optional[str]
    date: Optional[str]


class Qualification(BaseModel):
    """Represents an individual certification on the Qualification section"""

    title: str
    date: Optional[str]
    link: Optional[Link]


class Project(BaseModel):
    """Represents an individual project on the Project section"""
    title: str
    summary: str
    link: Optional[Link]


class Other(BaseModel):
    title: str
    summary: Optional[str]


class GenericSection(GenericModel, Generic[Content]):
    """Generic section used as a base class for other sections"""
    title: str
    list: List[Content]


class OtherSection(GenericSection[Other]):
    """The other section combines information from the `awards` and `publication` fields of a JSON resume"""
    @classmethod
    def from_jsonresume(cls, jsonresume: ResumeSchema) -> Optional[OtherSection]:
        # volunteer
        # publications
        # interests
        elements = chain(
            map(from_award, jsonresume.awards or []),
            map(from_publication, jsonresume.publications or []),
        )
        elements = list(elements)

        if elements:
            return OtherSection(title="Other", list=elements)
        else:
            return None


class ProjectSection(GenericSection[Project]):
    """The project section displays the same information as the `project` field of a JSON resume"""
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
    """The cualification section displays the same information as the `certifications` field of a JSON resume"""
    @classmethod
    def from_jsonresume(
        cls, jsonresume: ResumeSchema
    ) -> Optional[QualificationSection]:
        if not jsonresume.certificates:
            return None

        def inner(f: Certificate):
            return Qualification(
                title=f.name,
                date=str(f.date.year),
                link=Link(to=f.url, content=f.issuer),
            )

        formation = [inner(f) for f in sort_by_date(jsonresume.certificates)]
        return QualificationSection(title="Qualifications", list=formation)


class EducationSection(GenericSection[Education]):
    """The education section displays the same information as the `education` field of a JSON resume"""
    @classmethod
    def from_jsonresume(cls, jsonresume: ResumeSchema) -> Optional[EducationSection]:
        if not jsonresume.education:
            return None

        def inner(e: EducationItem) -> Education:
            d = glom(e, "endDate.year", default=None)
            return Education(
                title=f"{e.area}, {e.studyType}",
                institution=e.institution,
                summary=e.score,
                date=d,
            )

        education = [inner(e) for e in sort_by_date(jsonresume.education)]
        return EducationSection(title="Education", list=education)


class ExperienceSection(GenericSection[Experience]):
    """The experience section displays the same information as the `work` field of a JSON resume"""
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
    """The skills section displays the names of the skills from the `skills` field of a JSON resume"""
    cols: int = 6

    @classmethod
    def from_jsonresume(cls, jsonresume: ResumeSchema) -> Optional[SkillSection]:
        if jsonresume.skills is None:
            return None

        skills = [s.name for s in jsonresume.skills]
        return SkillSection(
            title="Skills",
            list=skills,
            cols=glom(jsonresume, "meta.latex.skills.cols", default=6),
        )


class SummarySection(BaseModel):
    """The summary section displays the contents `basics.summary` of a JSON resume"""
    title: str
    content: str

    @classmethod
    def from_jsonresume(cls, jsonresume: ResumeSchema) -> SummarySection:
        return SummarySection(title="Summary", content=jsonresume.basics.summary)


class ColumnSection(BaseModel):
    """The column section displays two columns with useful information from the author generated from the `basics` field of a JSON resume"""
    left: List[Column]
    right: List[Column]

    @classmethod
    def from_jsonresume(cls, jsonresume: ResumeSchema) -> ColumnSection:
        basic_columns_strategies = [
            extract.label_column,
            extract.mail_column,
            extract.phone_column,
            extract.location_column,
            extract.website_column,
        ]
        basic_columns = (f(jsonresume) for f in basic_columns_strategies)
        profile_columns = (
            Column(title=p.network, link=Link(to=p.url, content=p.username))
            for p in jsonresume.basics.profiles
        )

        columns = chain(basic_columns, profile_columns)
        columns = list(columns)
        middle = ceil(len(columns) / 2)
        return ColumnSection(left=columns[:middle], right=columns[middle:])


class TemplateScheme(BaseModel):
    """The model used to generate a LaTeX document"""
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
    column: ColumnSection
    summary: SummarySection
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
        inner = lambda x: glom(jsonresume, x, default=None)

        return TemplateScheme(
            mainfont=inner("meta.latex.mainfont"),
            title=inner("meta.title"),
            name=inner("basics.name"),
            keywords=extract.keywords(jsonresume),
            fontsize=inner("meta.latex.fontsize"),
            fontenc=inner("meta.latex.fontenc"),
            urlcolor=inner("meta.latex.urlcolor"),
            linkcolor=inner("meta.latex.linkcolor"),
            numbersections=inner("meta.latex.numbersections"),
            ruler=inner("meta.latex.ruler"),
            column=ColumnSection.from_jsonresume(jsonresume),
            summary=SummarySection.from_jsonresume(jsonresume),
            skills=SkillSection.from_jsonresume(jsonresume),
            experience=ExperienceSection.from_jsonresume(jsonresume),
            education=EducationSection.from_jsonresume(jsonresume),
            formation=QualificationSection.from_jsonresume(jsonresume),
            project=ProjectSection.from_jsonresume(jsonresume),
            other=OtherSection.from_jsonresume(jsonresume),
        )
