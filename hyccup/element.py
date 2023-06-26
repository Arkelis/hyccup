"""Functions for creating generic HTML elements."""
import hyccup.util as util
from hyccup.definition import defelem


def javascript_tag(script):
    """Wrap the supplied javascript up in script tags and a CDATA section."""
    return ["script", {"type": "text/javascript"}, f"//<![CDATA[\n{script}\n//]]>"]


@defelem
def link_to(url, *content):
    """Wrap some content in a HTML hyperlink with the supplied URL.

    :param attrs-map: Optional dict of attributes as first positional parameter
    :param url: The hypertext link
    :param \\*content: Content do include as children
    """
    return ["a", {"href": util.to_uri(url)}, *content]


@defelem
def mail_to(email, *content):
    """Wrap some content in a HTML hyperlink with the supplied e-mail address.

    If no content provided use the e-mail address as content.

    :param attrs-map: Optional dict of attributes as first positional parameter
    :param email: E-mail address
    :param \\*content: Content do include as children
    """
    if not content:
        return ["a", {"href": f"mailto:{email}"}, email]

    return ["a", {"href": f"mailto:{email}"}, *content]


@defelem
def unordered_list(coll):
    """Wrap a collection in an unordered list.

    :param attrs-map: Optional dict of attributes as first positional parameter
    :param coll: Collection of elements of the list.
    """
    return ["ul", (["li", x] for x in coll)]


@defelem
def ordered_list(coll):
    """Wrap a collection in an ordered list.

    :param attrs-map: Optional dict of attributes as first positional parameter
    :param coll: Collection of elements of the list.
    """
    return ["ol", (["li", x] for x in coll)]


@defelem
def image(src, alt=None):
    """Create an image element.

    :param attrs-map: Optional dict of attributes as first positional parameter
    :param src: The source of the image
    :param alt: Alternative text for the image
    """
    return ["img", {"src": util.to_uri(src), "alt": alt}]
