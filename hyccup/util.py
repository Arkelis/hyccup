import threading
from typing import Iterable
from contextlib import contextmanager
from functools import singledispatch
from fractions import Fraction
from urllib.parse import SplitResult, urlsplit, urlencode, quote_plus
from hy.models import Keyword, Symbol
from functools import reduce
from operator import add

local_data = threading.local()
local_data.encoding = None
local_data.base_url = ""


def to_str(obj):
    """Convert any object to string.

    In particular:

    * Convert fraction to string of its decimal result.
    * Convert a ``url.parse.SplitResult`` object to its URL with :hy:func:`str-of-url`.
    * For any other case, convert with ``str`` constructor."""
    return (
        str(float(obj))
        if isinstance(obj, Fraction)
        else str_of_url(obj)
        if isinstance(obj, SplitResult)
        else str(obj)
        if True
        else None
    )


def as_str(*obj):
    """Convert all passed objects to string with :hy:func:`to-str`."""
    return "".join(map(to_str, obj))


def escape_html(string, mode, escape_strings):
    """Change special characters into HTML character entities."""
    return (
        string.replace("&", "&amp;")
        .replace("<", "&lt;")
        .replace(">", "&gt;")
        .replace('"', "&quot;")
        .replace("'", "&#39;" if str(mode) == "sgml" else "&apos;")
        if escape_strings
        else string
    )


class RawStr(str):
    """Raw string class, subclass of ``str``.

    Instances of this class are not escaped.
    """

    __slots__ = ()

    @classmethod
    def from_obj_or_iterable(cls, obj):
        """Produce a raw string from an object or a collection."""
        if obj is None:
            return RawStr("")

        if is_coll(obj):
            return reduce(add, map(RawStr.from_obj_or_iterable, obj))

        return RawStr(obj)

    def __add__(self, other):
        return RawStr(super().__add__(other))


def url(*parts, **query_params):
    """Convert parts of an URL and query params to a ``url.parse.SplitResult``."""
    return to_uri("".join(parts) + url_encode(query_params))


@contextmanager
def base_url(url):
    """Context manager specifying base URL for URLs.

    .. tab:: Hy

        .. code-block:: clj

            => (with [(base-url "/foo")]
            ...  (setv my-url (to-str (to-uri "/bar"))))
            => (print my-url)
            "/foo/bar"

    .. tab:: Python

        .. code-block::

            >>> with base_url('/foo'):
            ...     my_url = to_str(to_uri('/bar'))
            ...
            >>> print(my-url)
            /foo/bar
    """
    try:
        local_data.base_url = url
        _hy_anon_var_1 = yield None
    finally:
        local_data.base_url = ""
    return _hy_anon_var_1


@contextmanager
def encoding(enc):
    """Context manager specifying encoding.

    .. tab:: Hy

        .. code-block:: clj

            => (with [(encoding "UTF-8")]
            ...  (url-encode {"iroha" "いろは"}))
            "iroha=%E3%81%84%E3%82%8D%E3%81%AF"
            => (with [(encoding "ISO-2022-JP")]
            ...  (url-encode {"iroha" "いろは"}))
            "iroha=%1B%24B%24%24%24m%24O%1B%28B"

    .. tab:: Python

        .. code-block::

            >>> with encoding('UTF-8'):
            ...     print(url_encode({'iroha': 'いろは'}))
            ...
            iroha=%E3%81%84%E3%82%8D%E3%81%AF
            >>> with encoding('ISO-2022-JP'):
            ...     print(url_encode({'iroha': 'いろは'}))
            ...
            iroha=%1B%24B%24%24%24m%24O%1B%28B

    """
    try:
        local_data.encoding = enc
        _hy_anon_var_2 = yield None
    finally:
        local_data.encoding = None
    return _hy_anon_var_2


def str_of_url(split_result):
    """Make URL from ``url.parse.SplitResult`` object."""
    if (
        split_result.netloc
        or None is split_result.path
        or (not split_result.path.startswith("/"))
    ):
        _hy_anon_var_3 = split_result.geturl()
    else:
        it = getattr(local_data, "base_url", "")
        it = it.removesuffix("/")
        it = it + split_result.path
        it = split_result._replace(path=it)
        it = it.geturl()
        _hy_anon_var_3 = it
    return _hy_anon_var_3


def url_encode(obj):
    """Quote `obj` for URL encoding.

    * If `obj` is a dict, use ``url.parse.urlencode``.
    * Else use ``url.parse.quote_plus``.
    """
    if isinstance(obj, dict):
        return urlencode(obj, encoding=getattr(local_data, "encoding", None))

    return quote_plus(obj)


def to_uri(obj):
    """Convert an object to a ``url.parse.SplitResult``."""
    match obj:
        case str(string):
            return urlsplit(string)
        case SplitResult(uri):
            return uri
        case _:
            return urlsplit(str(obj))


def is_empty(seq):
    """Assert that seq has no element."""
    return len(seq) == 0


def is_coll(obj):
    """Assert if obj is a collection but not a string or a bytes string."""
    if isinstance(obj, str) or isinstance(obj, bytes):
        return False

    return isinstance(obj, Iterable)
