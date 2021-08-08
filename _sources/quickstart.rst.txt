==========
Quickstart
==========

Installation
============

From PyPI:

.. code-block:: sh

    # with pip
    pip install hyccup

    # with poetry
    poetry add --pre hyccup


Overview
========

Use the :hy:func:`html <hyccup.core.html>` core function to render a data
structure into an HTML string:

.. tab:: Hy

   .. code-block:: clj

      => (import [hyccup.core [html]])
      => (html ['p {'id "an-id" 'class "a-class"} "Lorem Hypsum"])
      "<p class=\"a-class\" id=\"an-id\">Lorem Hypsum</p>"

.. tab:: Python

   .. code-block::

      >>> from hyccup.core import html
      >>> html(["p", {"id": "an-id", "class": "a-class"}, "Python Ipsum"])
      '<p class="a-class" id="an-id">Python Ipsum</p>'

The :hy:func:`html <hyccup.core.html>` function takes lists as positional
arguments. The first elmement of each list must be the tag name of the element
to render. It can be a string or a Hy symbol.

.. tab:: Hy

   .. code-block:: clj

      => (html ['p])
      "<p></p>"
      => (html ['br])
      "<br />"

.. tab:: Python

   .. code-block::

      >>> html(["p"])
      '<p></p>'
      >>> html(["br"])
      '<br />'

The attributes of the element must be represented in a dictionary as the
second element of the list.

.. tab:: Hy

   .. code-block:: clj

      => (html ['input {'type "password" 'name "password"}])
      "<input name=\"password\" type=\"password\" />"
      => (html ['p "Attributes dict can be omitted"])
      "<p>Attributes dict can be omitted</p>"

.. tab:: Python

   .. code-block::

      >>> html(["input", {"type": "password", "name": "password"}])
      '<input name="password" type="password" />'
      >>> html(["p", "Attributes dict can be omitted"])
      '<p>Attributes dict can be omitted</p>'


The other elements provided in the list are considered as the children
of the element. If an element is an iterator, it is expanded.

.. tab:: Hy

   .. code-block:: clj

      => (setv items-generator
           (gfor x (range 5) ['li f"Item #{x}"]))
      => (html ['ol items-generator])
      "<ol>
        <li>Item #0</li>
        <li>Item #1</li>
        <li>Item #2</li>
        <li>Item #3</li>
        <li>Item #4</li>
      </ol>"
      => (setv items-list
           (lfor x (range 5) ['li f"Item #{x}"]))
      => (html ['p "For other collections use unpacking or iter:"]
      ...      ['ul #* items-list (iter items-list)])
      "<p>For other collections use unpacking:</p>
      <ul>
        <li>Item #0</li>
        <li>Item #1</li>
        <li>Item #2</li>
        <li>Item #3</li>
        <li>Item #4</li>
        <li>Item #0</li>
        <li>Item #1</li>
        <li>Item #2</li>
        <li>Item #3</li>
        <li>Item #4</li>
      </ul>"

.. tab:: Python

   .. code-block::

      >>> items_generator = (["li", f"Item #{x}"] for x in range(5))
      >>> html(["ol", items_generator])
      '<ol>
        <li>Item #0</li>
        <li>Item #1</li>
        <li>Item #2</li>
        <li>Item #3</li>
        <li>Item #4</li>
      </ol>'
      >>> items_list = [["li", f"Item #{x}"] for x in range(5)]
      >>> html(["p", "For other collections use unpacking or iter:"],
      ...      ["ul", *items_list, iter(items_list)])
      '<p>For other collections use unpacking:</p>
      <ul>
        <li>Item #0</li>
        <li>Item #1</li>
        <li>Item #2</li>
        <li>Item #3</li>
        <li>Item #4</li>
        <li>Item #0</li>
        <li>Item #1</li>
        <li>Item #2</li>
        <li>Item #3</li>
        <li>Item #4</li>
      </ul>'

CSS selectors syntax for classes and id can be used as a shortcut
(first the id, followed by the classes):

.. tab:: Hy

   .. code-block:: clj

      => (html ['div#guido.bdfl])
      "<div class=\"bdfl\" id=\"guido\"></div>"

.. tab:: Python

   .. code-block::

      >>> html(["div#guido.bdfl"])
      '<div class="bdfl" id="guido"></div>'
