=======================
Page - Create Documents
=======================

This module contains functions for rendering HTML documents.

Basic Example
-------------

.. tab:: Hy

    .. code-block:: clj

        (import hyccup.page [html5 include-css include-js])    

        (html5 ['p "hello world"])
        ;; "<!DOCTYPE html>\n<html><p>hello world</p></html>"

        (html5 
          ['head 
            #* (include-css "/my.css") 
            #* (include-js "/my.js")]
          ['body "hello world"])
        ;; "<!DOCTYPE html>
        ;; <html>
        ;; <head>
        ;;   <link href=\"/my.css\" rel=\"stylesheet\" type=\"text/css\">
        ;;   <script src=\"/my.js\" type=\"text/javascript\"></script>
        ;; </head>
        ;; <body>hello world</body>
        ;; </html>"

.. tab:: Python

    .. code-block::

        from hyccup.page import html5, include_js, include_css

        html5(['p', 'hello world'])
        # '<!DOCTYPE html>\n<html><p>hello world</p></html>'

        html5(['head', 
               *include-css('/my.css'),
               *include-js('/my.js')],
              ['body', 'hello world'])
        # '<!DOCTYPE html>
        # <html>
        # <head>
        #   <link href="/my.css" rel="stylesheet" type="text/css">
        #   <script src="/my.js" type="text/javascript"></script>
        # </head>
        # <body>hello world</body>
        # </html>'


API
---

**Source code:** `hyccup/page.hy <https://github.com/Arkelis/hyccup/blob/master/hyccup/page.hy>`_

.. hy:automodule:: hyccup.page
    :members: xhtml, html4, html5, include_css, include_js
    :member-order: bysource

