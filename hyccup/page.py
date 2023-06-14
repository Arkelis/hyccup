from hyccup import html, raw
import hyccup.util as util
from hyccup.definition import defelem


__all__ = ["xhtml", "html4", "html5", "include_css", "include_js"]


def html4(*contents):
    """Create a HTML 4 document with the supplied contents.

    The first argument may be an optional attribute map.
    """
    return html(doctype["html4"], ["html", *contents], mode="sgml")


def xhtml(*contents, lang=None, encoding="UTF-8"):
    """Create a XHTML 1.0 strict document with the supplied contents.

    :param lang: The language of the document
    :param encoding: The character encoding of the document (defaults to UTF-8).
    """
    [attrs, contents] = split_attrs_and_content(contents)
    return html(
        xml_declaration(encoding),
        doctype["xhtml-strict"],
        xhtml_tag(attrs, lang, *contents),
        mode="xhtml",
    )


def html5(*contents, lang=None, xml=False, encoding="UTF-8"):
    """Create a HTML5 document with the supplied contents.

    :param xml: If True, use html with xml mode.
    :param encoding: The character encoding of the document (defaults to UTF-8).
    :param lang: The language of the document.
    """
    [attrs, contents] = split_attrs_and_content(contents)
    return (
        html(
            xml_declaration(encoding),
            doctype["html5"],
            xhtml_tag(attrs, lang, *contents),
            mode="xml",
        )
        if xml
        else html(
            doctype["html5"],
            ["html", attrs | {"lang": lang}, *contents],
            mode="html",
        )
    )


def include_js(*scripts):
    """Include a list of external javascript files."""
    return [
        ["script", {"type": "text/javascript", "src": util.to_uri(script)}]
        for script in scripts
    ]


def include_css(*styles):
    """Include a list of external stylesheet files."""
    return [
        ["link", {"type": "text/css", "href": util.to_uri(style), "rel": "stylesheet"}]
        for style in styles
    ]


doctype = {
    "html4": raw(
        '<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01//EN" "http://www.w3.org/TR/html4/strict.dtd">\n',
    ),
    "xhtml-strict": raw(
        '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">\n',
    ),
    "xhtml-transitional": raw(
        '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">\n',
    ),
    "html5": raw("<!DOCTYPE html>\n"),
}


@defelem
def xhtml_tag(lang, *contents):
    """Create an XHTML element for the specified language."""
    return [
        "html",
        {"xmlns": "http://www.w3.org/1999/xhtml", "xml:lang": lang, "lang": lang},
        *contents,
    ]


def xml_declaration(encoding):
    """Create a standard XML declaration for the following encoding."""
    return raw(['<?xml version="1.0" encoding="', encoding, '"?>\n'])


def split_attrs_and_content(contents):
    if isinstance(contents[0], dict):
        attrs, *rest = contents
        return (attrs, rest)

    return ({}, contents)
