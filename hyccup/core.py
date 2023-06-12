from hyccup.compiler import Compiler, RawStr


def html(*content, mode="xhtml", escape_strings=True):
    """Compile data structure into an HTML raw string.

    RawStr is a subclass of str, so it can be manipulated just like a string.

    :param \\*content: One or more lists representing HTML to render.
    :param mode: The HTML mode: ``"html"`` / ``"xml"`` / ``"xhtml"`` (default).
    :param escape-strings: Boolean indicating if strings must be escaped
                          (default: ``True``).
    :rtype: :class:`hyccup.util.RawStr`
    """
    compiled_content = Compiler(mode, escape_strings).compile_html(*content)
    return raw(compiled_content)


def raw(obj):
    """Produce a raw string from obj.

    Raw strings are not escaped.
    If `obj` is a collection, concatenate the string representation of the
    contained elements.

    :rtype: :class:`hyccup.util.RawStr`
    """
    return RawStr.from_obj_or_iterable(obj)
