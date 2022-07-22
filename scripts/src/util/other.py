from __future__ import annotations

from ..model import jsonresume, template


def from_award(award: jsonresume.Award) -> template.Other:
    return template.Other(
        title=award.title, summary=f"{award.awarder}. {award.date.year}"
    )


def from_publication(publication: jsonresume.Publication) -> template.Other:
    summary = f"\\href{{{publication.url}}}{{{publication.publisher}}}. {publication.releaseDate.year}"
    return template.Other(
        title=publication.name,
        summary=summary,
    )
