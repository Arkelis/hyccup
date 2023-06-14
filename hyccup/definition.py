import functools
from hyccup import html


def defhtml(func=None, /, **html_options):
    """Decorate a function for passing its result to ``html``.

    Take HTML options as keyword arguments.
    """

    # if HTML option is provided, we only have one func arg
    # then we simply call it and wrap its result with html()
    if callable(func):

        @functools.wraps(func)
        def wrapper(*args, **kwargs):
            return html(func(*args, **kwargs))

        return wrapper

    # else if we have HTML options, we need to define a parametrized decorator
    # we define a deco() function which will accept a callable as argument.
    # it will wrap its result with html() and give it provided HTML options.
    def deco(function):
        @functools.wraps(function)
        def wrapper(*args, **kwargs):
            return html(function(*args, **kwargs), **html_options)

        return wrapper

    return deco


def _split_args(args, kwargs, method=False):
    if not method:
        match (args, kwargs):
            case [[dict() as attrs_map, *others], kwargs]:
                return (attrs_map, others, kwargs)
            case [[], {"attrs_map": dict() as attrs_map, **others}]:
                return (attrs_map, (), others)
            case _:
                return (None, args, kwargs)

    else:
        match (args, kwargs):
            case [[self, dict() as attrs_map, *others], kwargs]:
                return (self, attrs_map, others, kwargs)
            case [[self], {"attrs_map": dict() as attrs_map, **others}]:
                return (self, attrs_map, (), others)
            case _:
                self, *other_args = args
                return (self, None, other_args, kwargs)

def defelem(function):
    """Decorate a function for defining elements.

    The returned object is a callable with two signature:

    * The original signature of the function
    * The original signature with as first parameter a dict of attributes. This
      will be merged with attributes of the returned element.
    """

    @functools.wraps(function)
    def wrapper(*args, **kwargs):
        attrs_map, args, kwargs = _split_args(args, kwargs)
        raw_result = function(*args, **kwargs)
        if attrs_map:
            tag, *body = raw_result

            if body and isinstance(body[0], dict):
                attrs_from_result, *rest = body
                return [tag, attrs_from_result | attrs_map, *rest]
            else:
                return [tag, attrs_map, *body]

        else:
            return raw_result

    return wrapper


def _defelemmethod(method):
    """defelem for methods"""
    @functools.wraps(method)
    def wrapper(*args, **kwargs):
        self, attrs_map, args, kwargs = _split_args(args, kwargs, method=True)
        raw_result = method(self, *args, **kwargs)
        if attrs_map:
            tag, *body = raw_result

            if body and isinstance(body[0], dict):
                attrs_from_result, *rest = body
                return [tag, attrs_from_result | attrs_map, *rest]
            else:
                return [tag, attrs_map, *body]

        else:
            return raw_result

    return wrapper


defelem.method = _defelemmethod