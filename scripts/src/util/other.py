from __future__ import annotations

from ..model import jsonresume, template


def from_award(award: jsonresume.Award) -> template.Other:
    """Uses an Award to generate an Other entry

    Example
    =======

    **First place**: Cambridge University. 2020
    """
    return template.Other(
        title=award.title, summary=f"{award.awarder}. {award.date.year}"
    )


def from_publication(publication: jsonresume.Publication) -> template.Other:
    """Uses a publication to generate an Other entry

    Example
    =======

    **Serverless on embedded devices**: [MIT](https://example.org). 2020
    """
    summary = f"\\href{{{publication.url}}}{{{publication.publisher}}}. {publication.releaseDate.year}"
    return template.Other(
        title=publication.name,
        summary=summary,
    )
