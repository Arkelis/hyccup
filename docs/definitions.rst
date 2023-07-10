===========================================
Definitions - Create Renderers and Elements
===========================================

This module contains helpers for defining callables returning HTML elements
structures or HTML raw strings directly.

Use :py:func:`~hyccup.definition.defhtml` for defining a callable
which passes its output to :py:func:`~hyccup.core.html` automatically:

.. code-block::

    from hyccup.definition import defhtml

    @defhtml
    def render_in_div(*content):
        return ["div", {"class": "container"}, *content]

    render_in_div(["ol", (["li", (f"Item {x}" for x in range(1, 4))])])
    # '<div class="container">
    #   <ol>
    #     <li>Item 1</li>
    #     <li>Item 2</li>
    #     <li>Item 3</li>
    #   </ol>
    # </div>'

You can pass HTML options:

.. code-block::

    # XHTML mode (default)
    @defhtml(mode="xhtml")
    def render_in_div(*content):
        return ["div", {"class": "container"}, *content]

    render_in_div(['img', {'src': 'https://foo.bar'}])
    # '<div class="container"><img src="https://foo.bar" /></div>'

    # HTML mode
    @defhtml(mode="html")
    def render_in_div(*content):
        return ["div", {"class": "container"}, *content]

    render_in_div(['img', {'src': 'https://foo.bar'}])
    # '<div class="container"><img src="https://foo.bar"></div>'


Use :py:func:`~hyccup.definition.defelem` for defining elements. You can
pass a dict of attributes as first optional parameter, it will be merged
with attributes of the returned element of the function.

.. code-block::

    from hyccup.definition import defelem

    @defelem
    def link_to(link, content):
        return ['a', {'href': link}, content])

    # Without attributes dict
    link_to('https://foo.bar', 'Awesome link')
    # ['a', {'href': 'https://foo.bar'}, 'Awesome link']

    # With attributes
    link_to({'class': 'some-class'}, 'https://foo.bar', 'Awesome link')
    # ['a {'href': 'https://foo.bar', 'class': 'some-class'} "Awesome link"]

For methods, use :code:`defelem.method`.

.. code-block::

    from hyccup.definition import defelem

    class Renderer:
        def __init__(self, base):
            self.base = base

        @defelem.method
        def link_to(self, path, content):
            return ['a', {'href': f"{self.base}{path}"}, content])

    renderer = Renderer('https://foo.bar')

    # Without attributes dict
    renderer.link_to('/path', 'Awesome link')
    # ['a', {'href': 'https://foo.bar/path'}, 'Awesome link']

    # With attributes
    renderer.link_to({'class': 'some-class'}, '/path', 'Awesome link')
    # ['a {'href': 'https://foo.bar/path', 'class': 'some-class'} "Awesome link"]


API
===

**Source code:** `hyccup/definition.py <https://github.com/Arkelis/hyccup/blob/master/hyccup/definition.py>`_

.. automodule:: hyccup.definition
    :members: defhtml, defelem
    :member-order: bysource
