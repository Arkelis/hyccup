===========================================
Definitions - Create Renderers and Elements
===========================================

This module contains helper for defining callables returning HTML elements
structures or HTML raw strings directly. They are available in two forms:

* Macros usable in Hy
* Decorators usable in both Hy and Python

Definitions Macros
==================

Overview
--------

Use :hy:macro:`defhtml <hyccup.defmacros.defhtml>` for defining a callable
which wraps its output to :hy:func:`html <hyccup.core.html>` automatically:

.. code-block:: clj

    ;; Use require to import macros
    (require [hyccup.defmacros [defhtml]])

    (defhtml render-in-div [#* content]
      ['div {'class "container"} (iter content)])
    (render-in-div ['ol (gfor x (range 1 4) ['li f"Item {x}"])])
    ;; "<div class=\"container\">
    ;;   <ol>
    ;;     <li>Item 1</li>
    ;;     <li>Item 2</li>
    ;;     <li>Item 3</li>
    ;;   </ol>
    ;; </div>"

You can pass HTML options:

.. code-block:: clj

    ;; XHTML mode (default)
    (defhtml {"mode" "xhtml"} render-in-div [#* content]
      ['div {'class "container"} (iter content)])
    (render-in-div ['img {'src "https://foo.bar"}])
    ;; "<div class=\"container\"><img src=\"https://foo.bar\" /></div>"

    ;; HTML mode
    (defhtml {"mode" "html"} render-in-div [#* content]
      ['div {'class "container"} (iter content)])
    (render-in-div ['img {'src "https://foo.bar"}])
    ;; "<div class=\"container\"><img src=\"https://foo.bar\"></div>"


Use :hy:macro:`defelem <hyccup.defmacros.defelem>` for defining elements. A
first optional parameter is added for specifying attributes to merge with 
returned element's attributes:

.. code-block:: clj

    (require [hyccup.defmacros [defelem]])

    (defelem link-to [link content]
      ['a {'href link} content])

    ;; Without attributes dict
    (link-to "https://foo.bar" "Awesome link")
    ;; ['a {'href "https://foo.bar"} "Awesome link"]

    ;; With attributes
    (link-to {'class "some-class"} "https://foo.bar" "Awesome link")
    ;; ['a {'href "https://foo.bar" 'class "some-class"} "Awesome link"]


API
---

**Source code:** `hyccup/defmacros.hy <https://github.com/Arkelis/hyccup/blob/master/hyccup/defmacros.hy>`_

.. hy:automodule:: hyccup.defmacros
    :members:

Definitions Decorators
======================

Overview
--------

Use :hy:func:`defhtml <hyccup.defdecos.defhtml>` for defining a callable
which wraps its output to :hy:func:`html <hyccup.core.html>` automatically:

.. code-block::

    from hyccup.defdecos import defhtml

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


Use :hy:macro:`defelem <hyccup.defdecos.defelem>` for defining elements. A
first optional parameter is added for specifying attributes to merge with 
returned element's attributes:

.. code-block::

    from hyccup.defdecos import defelem

    @defelem
    def link_to(link, content):
        return ['a', {'href': link}, content])

    # Without attributes dict
    link_to('https://foo.bar', 'Awesome link')
    # ['a', {'href': 'https://foo.bar'}, 'Awesome link']

    # With attributes
    link_to({'class': 'some-class'}, 'https://foo.bar', 'Awesome link')
    # ['a {'href': 'https://foo.bar', 'class': 'some-class'} "Awesome link"]

API
---

**Source code:** `hyccup/defdecos.hy <https://github.com/Arkelis/hyccup/blob/master/hyccup/defdecos.hy>`_

.. hy:automodule:: hyccup.defdecos
    :members:
