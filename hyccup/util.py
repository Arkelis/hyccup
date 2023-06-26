from typing import Iterable
from contextlib import contextmanager
from fractions import Fraction
from urllib.parse import SplitResult, urlsplit, urlencode, quote_plus
from functools import reduce
from operator import add



def to_str(obj):
    """Convert any object to string.

    In particular:

    * Convert fraction to string of its decimal result.
    * Convert a ``url.parse.SplitResult`` object to its URL with :hy:func:`str-of-url`.
    * For any other case, convert with ``str`` constructor."""
    if isinstance(obj, Fraction):
        return str(float(obj))

    if isinstance(obj, SplitResult):
        return obj.geturl()

    return str(obj)


def as_str(*obj):
    """Convert all passed objects to string with :hy:func:`to-str`."""
    return "".join(map(to_str, obj))


def escape_html(string, mode, escape_strings):
    """Change special characters into HTML character entities."""
    if not escape_strings:
        return string

    return (
        string.replace("&", "&amp;")
        .replace("<", "&lt;")
        .replace(">", "&gt;")
        .replace('"', "&quot;")
        .replace("'", "&#39;" if str(mode) == "sgml" else "&apos;")
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


@contextmanager
def base_url(url, / ,encoding=None):
    """Context manager specifying base URL for URLs.

    .. tab:: Hy

        .. code-block:: clj

            => (with [b (base-url "/foo")]
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
    yield UrlBase(url, encoding=encoding)


class UrlBase:
    def __init__(self, base="", encoding=None):
        self.base = base.removesuffix("/")
        self.encoder = Encoder(encoding)

    def _with_base(self, split_result):
        return split_result._replace(path=self.base + split_result.path)
     
    def to_uri(self, obj):
        """Convert an object to a ``url.parse.SplitResult``."""
        match obj:
            case str(string):
                split_result = urlsplit(string)
            case SplitResult(uri):
                split_result = uri
            case _:
                raise TypeError(f"{obj} should be urllib.parse.SplitResult or str instance. "
                                f"({type(obj)} received)")
        
        if (
            split_result.netloc
            or split_result.path is None
            or (not split_result.path.startswith("/"))
        ):
            return split_result

        return self._with_base(split_result)
    
    def url(self, *parts, **query_params):
        """Convert parts of an URL and query params to a ``url.parse.SplitResult``."""
        return self.to_uri("".join(parts) + "?" + self.encoder.url_encode(query_params))


@contextmanager
def encoding(enc):
    """Context manager specifying encoding.

    .. tab:: Hy

        .. code-block:: clj

            => (with [e (encoding "UTF-8")]
            ...  (e.url-encode {"iroha" "いろは"}))
            "iroha=%E3%81%84%E3%82%8D%E3%81%AF"
            => (with [e (encoding "ISO-2022-JP")]
            ...  (e.url-encode {"iroha" "いろは"}))
            "iroha=%1B%24B%24%24%24m%24O%1B%28B"

    .. tab:: Python

        .. code-block::

            >>> with encoding('UTF-8') as e:
            ...     print(e.url_encode({'iroha': 'いろは'}))
            ...
            iroha=%E3%81%84%E3%82%8D%E3%81%AF
            >>> with encoding('ISO-2022-JP') as e:
            ...     print(e.url_encode({'iroha': 'いろは'}))
            ...
            iroha=%1B%24B%24%24%24m%24O%1B%28B

    """
    yield Encoder(enc)


class Encoder:
    def __init__(self, encoding=None):
        self.encoding = encoding
    
    def url_encode(self, obj):
        if isinstance(obj, dict):
            return urlencode(obj, encoding=self.encoding)

        return quote_plus(obj)


def url_encode(obj):
    """Quote `obj` for URL encoding.

    * If `obj` is a dict, use ``url.parse.urlencode``.
    * Else use ``url.parse.quote_plus``.
    """
    return Encoder().url_encode(obj)


def to_uri(obj):
    """Convert an object to a ``url.parse.SplitResult``."""
    return UrlBase().to_uri(obj)

def url(*parts, **query_params):
    """Convert parts of an URL and query params to a ``url.parse.SplitResult``."""
    return UrlBase().url(*parts, **query_params)


def is_empty(seq):
    """Assert that seq has no element."""
    return len(seq) == 0


def is_coll(obj):
    """Assert if obj is a collection but not a string or a bytes string."""
    if isinstance(obj, str) or isinstance(obj, bytes):
        return False

    return isinstance(obj, Iterable)
