Coming from Hiccup
==================

Hyccup can be considered as Hiccup ported to Hy and Python. However,
some API elements must adapted to Python's mindset. This page shows
the main difference between this library and Hiccup.

Keywords
--------

As keywords are not a Python concept and as Hy is very close to Python,
they cannot be used efficiently. Thus, we rely on strings or symbols
instead.

That is to say,

.. code:: clj

   [:div#an-id {:class "a-class"} "some text"]

must be changed to

.. code:: clj

   ["div#an-id" {"class" "a-class"} "some text"] ;; with strings
   ['div#an-id {'class "a-class"} "some text"] ;; with symbols

HTML Options
------------

Instead of passing options in a dictionary as the first argument:

.. code:: clj

   (html {:mode "xhtml" :espace-strings? true} [:p "example"])

Pass them as keyword arguments (or use unpacking):

.. code:: clj

   (html ['p "example"] :mode "xhtml" :espace-strings True)
   (html ['p "example"] #** {'mode "xhtml" 'espace-strings True})
   (html ['p "example"] (unpack-mapping {'mode "xhtml" 'espace-strings True}))

Note that the escape flag argument has no ``?`` suffix in Hyccup.

Lists
-----

The following form is valid in Hiccup:

.. code:: clj

   (html (list [:p "some text"] [:p "another p"]))

In Hyccup, just chain the elements or use unpacking (as we already use
lists to represent elements, where Hiccup use Clojure vectors).

.. code:: clj

   (html ['p "some text"] ['p "another p"]))
   (html #* [['p "some text"] ['p "another p"]]))
   (html (unpack-iterable [['p "some text"] ['p "another p"]])))

You can also use iterators:

.. code:: clj

   (html (iter [['p "some text"] ['p "another p"]]))

``with-*`` macros
-----------------

``with-base-url`` and ``with-encoding`` are replaced by context
managers.

Change

.. code:: clj

   => (with-base-url "/foo/" 
        (to-str (to-uri "/bar")))
   "/foo/bar"
   => (with-encoding "UTF-8" 
        (url-encode {:iroha "いろは"}))
   "iroha=%E3%81%84%E3%82%8D%E3%81%AF"

To

.. code:: clj

   => (with [(base-url "/foo/")]
        (to-str (to-uri "/bar")))
   "/foo/bar"
   => (with [(encoding "UTF-8")] 
        (url-encode {'iroha "いろは"}))
   "iroha=%E3%81%84%E3%82%8D%E3%81%AF"

``defhtml`` and ``defelem``
---------------------------

``defhtml`` and ``defelem`` macros from Hiccup is available in two
modules, macros for Hy and decorators for Python:


.. tab:: Hy

   .. code:: clj

      => (require [hyccup.defmacros [defhtml defelem]])
      => (defelem link-to [link text]
      ...  ['a {'href link} text])
      => (link-to {'class "some-class"} "https://www.pycolore.fr" "Pycolore" )
      ['a {'href "https://www.pycolore.fr" 'class "some-class"} "Pycolore"]
      => (defhtml linked-section-html [link text content]
      ...  ['section 
      ...    ['h1 (link-to link text)]
      ...    ['p content]])
      => (linked-section-html "https://www.pycolore.fr" "Pycolore" "Lorem Ipsum")
      "<section>
         <h1>
         <a href="https://www.pycolore.fr">Pycolore</a>
         </h1>
         <p>
         Lorem Ipsum
         </p>
      </section>"
      => 
      => (defhtml {"mode" "xml"} ;; you can pass HTML options as first form to defhtml
           some-html []
           ['p])
      => (some-html)
      "<p />" 


.. tab:: Python

   .. code::

      >>> from hyccup.defdecos import defelem, defhtml
      >>> @defhtml # pass output of function to html()
      ... @defelem # merge first arg dict with attributes
      ... def link_to(link: str, text: str):
      ...     return ["a", {"href": link}, text]
      ...
      >>> link_to({"class": "some-class"}, "https://www.pycolore.fr", "Pycolore")
      '<a class="some-class" href="https://www.pycolore.fr">Pycolore</a>'
      >>> @defhtml(mode="html") # it is possible to pass HTML options to defhtml
      ... def paragraph(content=""):
      ...     return ["p", content]
      ...
      >>> paragraph()
      '<p></p>'

