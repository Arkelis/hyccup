from hyccup.util import escape_html, RawStr, is_empty, to_str
import re
from hyrule import is_coll
from itertools import filterfalse
from collections.abc import Iterator


def is_xml_mode(mode):
    return str(mode) in {"xml", "xhtml"}


def is_html_mode(mode):
    return str(mode) in {"html", "xhtml"}


def is_void_tag(tag_name):
    return tag_name in {
        "area",
        "base",
        "br",
        "col",
        "command",
        "embed",
        "hr",
        "img",
        "input",
        "keygen",
        "link",
        "meta",
        "param",
        "source",
        "track",
        "wbr",
    }


def is_container_tag(tag_name, mode):
    return is_html_mode(mode) and not is_void_tag(tag_name)


def expand_tag_abb(tag):
    """Expand a tag abbreviation

    Take a str or symbol and return a list containing:
    - the name of the element
    - its id
    - its classes
    """
    tag_abbr_str = str(tag)
    tag_abbr_re = re.compile(r"([^\s\.#]+)(?:#([^\s\.#]+))?(?:\.([^\s#]+))?")
    name, id_, classes = tag_abbr_re.match(tag_abbr_str).group(1, 2, 3)
    formatted_classes = (classes or "").replace(".", " ")
    return [name, id_, formatted_classes]


class Compiler:
    def __init__(self, mode, escape_strings):
        self.mode = mode
        self.escape_strings = escape_strings

    def compile_html(self, *content):
        """Compile HTML content to string."""
        compiled_elements = (self.compile_element_exp(el) for el in content)
        return "".join(compiled_elements)

    def compile_element_exp(self, exp):
        """Compile any expression representing an element to a HTML string.

        Called by self.compile-html.
        """
        if isinstance(exp, Iterator):
            return ''.join(self.compile_element_exp(el) for el in exp)
        if isinstance(exp, list):
            return self.compile_list(exp)
        if isinstance(exp, RawStr):
            return exp
        if exp is None:
            return ""

        return escape_html(str(exp), self.mode, self.escape_strings)

    def compile_list(self, element_list):
        """Take an element list and call render-element to render it.

        Called by self.compile-element-exp.
        """
        match element_list:
            case [str(tag)]:
                return self.render_element(tag, {})
            case [str(tag), dict(attrs), *restt]:
                return self.render_element(tag, attrs, *restt)
            case [str(tag), *restt]:
                return self.render_element(tag, {}, *restt)
            case _:
                raise ValueError(f"{element_list} is not properly formatted")

    def render_element(self, tag, attrs, *children):
        """Render an element list to HTML string recursively.

        Take a tag, an attributes dictionary and children as positional arguments
        Take the HTML mode as keyword argument

        Return a string of the HTML representation of the element.
        Call compile-element-exp for rendering its children.
        Called by compile-list.
        """
        attributes = {str(k): v for k, v in attrs.items()}
        classes_from_attrs = attributes.get("class", "")
        tag_name, element_id, classes_from_abbr = expand_tag_abb(tag)
        if element_id and not "id" in attributes:
            attributes["id"] = element_id

        if classes_from_attrs or classes_from_abbr:
            attributes["class"] = " ".join(
                filterfalse(
                    is_empty,
                    [
                        classes_from_abbr,
                        " ".join(classes_from_attrs)
                        if is_coll(classes_from_attrs)
                        else classes_from_attrs,
                    ],
                )
            )

        if is_empty(children):
            return f"<{tag_name}{self.format_attrs_dict(attributes)}" + (
                f"></{tag_name}>"
                if is_container_tag(tag_name, self.mode)
                else " />"
                if is_xml_mode(self.mode)
                else ">"
            )

        if is_void_tag(tag_name):
            raise ValueError(f"'{tag_name}' cannot have children")

        compiled_children = "".join(map(self.compile_element_exp, children))
        return (
            f"<{tag_name}{self.format_attrs_dict(attributes)}>"
            + f"{compiled_children}"
            + f"</{tag_name}>"
        )

    def format_attr(self, attr, value):
        if value is True:
            return (
                f'{str(attr)}="{str(attr)}"'
                if is_xml_mode(self.mode)
                else f"{str(attr)}"
            )

        if not value:
            return ""

        attr_value = escape_html(to_str(value), self.mode, escape_strings=True)
        return f'{str(attr)}="{attr_value}"'

    def format_attrs_dict(self, attrs_dict):
        """Convert attributes dictionary to string."""
        if not attrs_dict:
            return ""

        formatted_attrs = (
            self.format_attr(attr, value) for attr, value in sorted(attrs_dict.items())
        )
        attrs_str = " ".join(filterfalse(is_empty, formatted_attrs))
        return f" {attrs_str}" if attrs_str else ""
