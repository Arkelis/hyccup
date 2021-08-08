# Hyccup

[![Tests](https://github.com/Arkelis/hyccup/actions/workflows/test.yml/badge.svg)](https://github.com/Arkelis/hyccup/actions/workflows/test.yml)

Hyccup is a port of [Hiccup](https://github.com/weavejester/hiccup)
for [Hy](https://github.com/hylang/hy), a Lisp embed in Python.

It allows you to represent HTML into data structure and to dump it.

```hy
=> (import [hyccup.core [html]])
=> (html ['div {'class "my-class" 'id "my-id"} "Hello Hyccup"])
"<div class=\"my-class\" id=\"my-id\">Hello Hyccup</div>"
```

## Differences with Hiccup

### Keywords

As keywords are not a Python concept and as Hy is very close to Python, they
cannot be used efficiently. Thus, we rely on strings or symbols instead.

That is to say, 

```hy
[:div#an-id {:class "a-class"} "some text"]
```
must be changed to

```hy
["div#an-id" {"class" "a-class"} "some text"] ;; with strings
['div#an-id {'class "a-class"} "some text"] ;; with symbols
```

### HTML Options

Instead of passing options in a dictionary as the first argument:

```clj
(html {:mode "xhtml" :espace-strings? true} [:p "example"])
```

Pass them as keyword arguments (or use unpacking):

```hy
(html ['p "example"] :mode "xhtml" :espace-strings True)
(html ['p "example"] #** {'mode "xhtml" 'espace-strings True})
(html ['p "example"] (unpack-mapping {'mode "xhtml" 'espace-strings True}))
```

Note that the escape flag argument has no `?` suffix in Hyccup.

### Lists

The following form is valid in Hiccup:

```clj
(html (list [:p "some text"] [:p "another p"]))
```

In Hyccup, just chain the elements or use unpacking (as we already use lists to
represent elements, where Hiccup use Clojure vectors).

```hy
(html ['p "some text"] ['p "another p"]))
(html #* [['p "some text"] ['p "another p"]]))
(html (unpack-iterable [['p "some text"] ['p "another p"]])))
```

### `with-*` macros 

`with-base-url` and `with-encoding` are replaced by context managers.

Change

```clj
=> (with-base-url "/foo/" 
     (to-str (to-uri "/bar")))
"/foo/bar"
=> (with-encoding "UTF-8" 
     (url-encode {:iroha "いろは"}))
"iroha=%E3%81%84%E3%82%8D%E3%81%AF"
```

To

```hy
=> (with [(base-url "/foo/")]
     (to-str (to-uri "/bar")))
"/foo/bar"
=> (with [(encoding "UTF-8")] 
     (url-encode {'iroha "いろは"}))
"iroha=%E3%81%84%E3%82%8D%E3%81%AF"
```


### `defhtml` and `defelem`


`defhtml` and `defelem` macros from Hiccup is available in two modules:

- `hyccup.defmacros` for using `defhtml` and `defelem` as macros in Hy code:

```hy
=> (require [hyccup.defmacros [defhtml defelem]])
=> (defelem link-to [link text]
...  ['a {'href link} text])
=> (link-to "https://www.pycolore.fr" "Pycolore" )
['a {'href "https://www.pycolore.fr"} "Pycolore"]
=> (defhtml linked-section-html [link text content]
...  ['section 
...    ['h1 (link-to link text)]
...    ['p content]])
=> (linked-section-html "https://www.pycolore.fr" "Pycolore" "Lorem Ipsum")
'<section>
   <h1>
     <a href="https://www.pycolore.fr">Pycolore</a>
   </h1>
   <p>
     Lorem Ipsum
   </p>
 </section>'
```

- `hyccup.defdecos` for using `defhtml` and `defelem`decorators in Python code. See *Python Interop* section.

## Python interop

You can call Hyccup functions from Python code:

```pycon
>>> import hy
>>> from hyccup.core import html
>>> html(["div", {"class": "my-class", "id": "my-id"}, "Hello Hyccup"])
'<div class="my-class" id="my-id">Hello Hyccup</div>'
```

`defelem` and `defhtml` macros are available as decorators in Python:

```pycon
>>> from hyccup.defdecos import defelem, defhtml
>>> @defhtml # pass output of function to html()
... @defelem # merge last arg dict with attributes
... def link_to(link: str, text: str):
...     return ["a", {"href": link}, text]
...
>>> link_to({"class": "some-class"}, "https://www.pycolore.fr", "Pycolore")
'<a class="some-class" href="https://www.pycolore.fr">Pycolore</a>'
```

It is possible to pass HTML options to `defhtml` decorator

```pycon
>>> @defhtml(mode="html")
... def paragraph(content=""):
...     return ["p", content]
...
>>> paragraph()
'<p></p>'
```

<!-- ## Use Hyccup with web frameworks

### Django

### Flask -->
