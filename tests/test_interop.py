"""Tests calling Hyccup from Python code"""

import pytest

from hyccup.core import html


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
