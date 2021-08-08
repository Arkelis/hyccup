.. Hyccup documentation master file, created by
   sphinx-quickstart on Mon Jul 26 23:05:23 2021.
   You can adapt this file completely to your liking, but it should at least
   contain the root `toctree` directive.

===========================================================
Hyccup - Generate HTML from data structure in Hy and Python
===========================================================


Hyccup is a port of `Hiccup <https://github.com/weavejester/hiccup>`_ for 
`Hy <https://github.com/hylang/hy>`_ and Python. It allows you to represent
HTML into data structure and to dump it:

.. tab:: Hy

   .. code-block:: clj

      => (import [hyccup.core [html]])
      => (html ['div {'class "greeting"} "Hello Hyccup from Hy!"])
      "<div class=\"greeting\">Hello Hyccup from Hy!</div>"

.. tab:: Python

   .. code-block:: pycon

      >>> from hyccup.core import html
      >>> html(["div", {"class": "greeting"}, "Hello Hyccup from Python!"])
      '<div class="greeting">Hello Hyccup from Python!</div>'


.. toctree::
   :maxdepth: 2
   
   quickstart.rst
   from-hiccup.rst
   reference.rst
