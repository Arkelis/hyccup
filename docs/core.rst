============================
Core Functions - Render HTML
============================

The core module contains the :hy:func:`html` function which renders HTML from data
structure. All strings are escaped by default; to prevent a string to be
escaped, use the :hy:func:`raw` function.

Syntax Reminder
===============

.. tab:: Hy

    .. code:: clj

      => (html ["p"])
      "<p><p/>"
      => (html ["p" "some text"])
      "<p>some text</p>"
      => (html ["p" {"attr" "an-attr"} "some text"])
      "<p attr="an-attr">some text</p>"
      => (html ["p" (dict :attr "an-attr")
                  ["div" "lorem"]
                  ["div" "ipsum"]])
      "<p attr="an-attr">
        <div>lorem</div>
        <div>ipsum</div>
      </p>"
      => (html ["p" {"attr" "an-attr"}
                  *[["div" "lorem"]
                    ["div" "ipsum"]]])
      "<p attr=\"an-attr\">
        <div>lorem</div>
        <div>ipsum</div>
      </p>"
      => (html ["p" {'attr "an-attr"}
                  (iter [["div" "lorem"]
                         ["div" "ipsum"]])])
      "<p attr=\"an-attr\">
        <div>lorem</div>
        <div>ipsum</div>
      </p>"

.. tab:: Python

    .. code-block::

      >>> html(['p'])
      '<p></p>'
      >>> html(['p', 'some text'])
      '<p>some text</p>'
      >>> html(['p', {'attr': 'an-attr'}, 'some text'])
      '<p attr="an-attr">some text</p>'
      >>> html(['p', {'attr': 'an-attr'},
                ['div', 'lorem'],
                ['div', 'ipsum']])
      '<p attr="an-attr">
        <div>lorem</div>
        <div>ipsum</div>
      </p>'
      >>> html(['p', {'attr': 'an-attr'},
                *[['div', 'lorem'],
                  ['div', 'ipsum']]])
      '<p attr="an-attr">
        <div>lorem</div>
        <div>ipsum</div>
      </p>'
      >>> html(['p', {'attr': 'an-attr'},
                iter([['div', 'lorem'],
                      ['div', 'ipsum']])])
      '<p attr="an-attr">
        <div>lorem</div>
        <div>ipsum</div>
      </p>'


String Escaping
===============

By default, :hy:func:`html` escapes all strings. This behaviour can be customized
with `escape-strings` parameter:

.. tab:: Hy

    .. code-block:: clj
        
        => (setv content ["p" "line<br>other"])
        => (html content :escape-strings False)
        "<p>line<br>other</p>"
  
.. tab:: Python

    .. code-block::

        >>> content = ['p', 'line<br>other']
        >>> html(content, escape_strings=False)
        '<p>line<br>other</p>'

:hy:func:`raw` function can be used to prevent a single expression to be escaped:

.. tab:: Hy

    .. code-block:: clj
        
        => (setv content ["p" (raw "line<br>other")])
        => (html content)
        "<p>line<br>other</p>"
  
.. tab:: Python

    .. code-block::

        >>> content = ['p', raw('line<br>other')]
        >>> html(content)
        '<p>line<br>other</p>'


Note that :hy:func:`html` returns a raw string:

.. tab:: Hy

    .. code-block:: clj
        
        => (setv content (html ["p" "some text"]))
        => (html ["div" content])
        "<div><p>some text</p></div>"
  
.. tab:: Python

    .. code-block::

        >>> content = html(['p', 'some text'])
        >>> html(['div', content])
        '<div><p>some text</p></div>'
        

API
===

**Source code:** `hyccup/core.hy <https://github.com/Arkelis/hyccup/blob/master/hyccup/core.hy>`_

.. hy:automodule:: hyccup.core
    :members: html, raw

