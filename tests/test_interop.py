"""Tests calling Hyccup from Python code

Test especially hyccup.defdecos module.
"""

import inspect

from hy.models import Symbol as S
import pytest

from hyccup import html
from hyccup.definition import defhtml, defelem
from hyccup.form import group, text_field


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
        assert two_args({"foo": "bar"}, 0, 1) == [1, {"foo": "bar"}, 0, 3]
    
    def test_args_syntaxes(self):
        @defelem
        def positional_only(a, /):
            return [a]
        
        assert positional_only({"foo": "bar"}, 1) == [1, {"foo": "bar"}]

        @defelem
        def positional_and_kw_only(a, /, b, *, c):
            return [a, b+c]
        
        assert positional_and_kw_only({"foo": "bar"}, 1, 2, c=3) == [1, {"foo": "bar"}, 5]
        
        @defelem
        def var_positional(a, *args, **kwargs):
            return [a, sum(args) + sum(kwargs.values())]
        
        assert var_positional({"foo": "bar"}, 1, 4, 5, b=6, c=7) == [1, {"foo": "bar"}, 22]

    def test_recursive(self):
        @defelem
        def rec(a):
            if a < 1:
                return [a, a+1]
            return rec(a-1)
        
        assert rec(4) == [0, 1]
        assert rec({"foo": "bar"}, 4) == [0, {"foo": "bar"}, 1]
    
    def test_merge_attrs(self):
        @defelem
        def with_map(a=1, b=2):
            return [a, {"foo": "bar"}, b]
        
        assert with_map() == [1, {"foo": "bar"}, 2]
        assert with_map({"a": "b"}) == [1, {"a": "b", "foo": "bar"}, 2]
        assert with_map(1, 2) == [1, {"foo": "bar"}, 2]
        assert with_map({"a": "b"}, 1, 2) == [1, {"a": "b", "foo": "bar"}, 2]
    
    def test_preserve_special_attrs(self):
        @defelem
        def some_func(a: int = 1, b: int = 2):
            """some func's docstring"""
            return [a, b]

        assert some_func.__name__ == "some_func"
        assert str(inspect.signature(some_func)) == "(a: int = 1, b: int = 2)"
        assert some_func.__doc__ == "some func's docstring"
        assert some_func.__annotations__ == {"a": int, "b": int}


class TestGroup:
    def test_simple_group(self):
        def a_form(names):
            with group("mygroup"):
                return [text_field(name) for name in names]

        assert a_form(["one", "two"]) == [
            ['input', {'id': 'mygroup-one', 'name': 'mygroup[one]', 'type': 'text', 'value': None}],
            ['input', {'id': 'mygroup-two', 'name': 'mygroup[two]', 'type': 'text', 'value': None}]]

    def test_multiple_groups(self):
        def inner_form():
            with group("inner"):
                return [text_field('three'), text_field('four')]

        def outer_form():
            with group("outer"):
                return [
                    text_field('one'),
                    text_field('two'),
                    *inner_form()]
        
        assert outer_form() == [
            ['input', {'id': 'outer-one', 'name': 'outer[one]', 'type': 'text', 'value': None}],
            ['input', {'id': 'outer-two', 'name': 'outer[two]', 'type': 'text', 'value': None}],
            ['input', {'id': 'outer-inner-three', 'name': 'outer[inner][three]', 'type': 'text', 'value': None}],
            ['input', {'id': 'outer-inner-four', 'name': 'outer[inner][four]', 'type': 'text', 'value': None}]]