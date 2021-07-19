"""Tests calling Hyccup from Python code"""

import inspect

import pytest

from hyccup.core import html
from hyccup.defdecos import defhtml, defelem


class TestCore:
    def test_html(self):
        assert (
            html(["div#my-id", {"class": "a-class"}, "some text"])
            == '<div class="a-class" id="my-id">some text</div>')

    def test_modes(self):
        assert html(["p"], mode="xml") == "<p />"
        assert html(["p"], mode="html") == "<p></p>"
    
    def test_unpacking_needed(self):
        assert html(["p", "text"], ["p", "text"]) == "<p>text</p><p>text</p>"
        assert html(*[["p", "text"], ["p", "text"]]) == "<p>text</p><p>text</p>"
        with pytest.raises(TypeError):
            html([["p", "text"], ["p", "text"]])


class TestDefHtmlDeco:
    def test_basic(self):
        @defhtml()
        def basic_fn(x):
            return ["span", x]
        
        @defhtml
        def basic_fn2(x):
            return ["span", x]
        
        assert basic_fn("foo") == "<span>foo</span>"
        assert basic_fn2("foo") == "<span>foo</span>"

    def test_mode(self):
        @defhtml(mode="html")
        def first(x):
            return ["div", ["p"], ["br"]]

        @defhtml(mode="xml")
        def second(x):
            return ["div", ["p"], ["br"]]
        
        assert first("foo") == "<div><p></p><br></div>"
        assert second("foo") == "<div><p /><br /></div>"


class TestDefElemDeco:
    def test_basic(self):
        @defelem
        def two_args(a, b):
            return [b, a, 3]
        
        assert two_args(0, 1) == [1, 0, 3]
        assert two_args(0, 1, {"foo": "bar"}) == [1, {"foo": "bar"}, 0, 3]
    
    def test_args_syntaxes(self):
        @defelem
        def positional_only(a, /):
            return [a]
        
        assert positional_only(1, {"foo": "bar"}) == [1, {"foo": "bar"}]

        @defelem
        def positional_and_kw_only(a, /, b, *, c):
            return [a, b+c]
        
        assert positional_and_kw_only(1, 2, {"foo": "bar"}, c=3) == [1, {"foo": "bar"}, 5]
        
        @defelem
        def var_positional(a, *args, **kwargs):
            return [a, sum(args) + sum(kwargs.values())]
        
        assert var_positional(1, {"foo": "bar"}, 4, 5, b=6, c=7) == [1, {"foo": "bar"}, 22]

    def test_recursive(self):
        @defelem
        def rec(a):
            if a < 1:
                return [a, a+1]
            return rec(a-1)
        
        assert rec(4) == [0, 1]
        assert rec(4, {"foo": "bar"}) == [0, {"foo": "bar"}, 1]
    
    def test_merge_attrs(self):
        @defelem
        def with_map(a=1, b=2):
            return [a, {"foo": "bar"}, b]
        
        assert with_map() == [1, {"foo": "bar"}, 2]
        assert with_map(attrs_map={"a": "b"}) == [1, {"a": "b", "foo": "bar"}, 2]
        assert with_map(1, 2) == [1, {"foo": "bar"}, 2]
        assert with_map(1, 2, {"a": "b"}) == [1, {"a": "b", "foo": "bar"}, 2]
    
    def test_preserve_special_attrs(self):
        @defelem
        def some_func(a: int = 1, b: int = 2):
            """some func's docstring"""
            return [a, b]

        assert some_func.__name__ == "some_func"
        assert str(inspect.signature(some_func)) == "(a: int = 1, b: int = 2, attrs_map=None)"
        assert some_func.__doc__ == "some func's docstring\n\nLast optional positional parameter added by 'defelem' decorator:\na dict of xml attributes to be added to the element."
        assert some_func.__annotations__ == {"a": int, "b": int}

