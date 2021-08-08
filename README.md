# Hyccup

[![PyPi](https://img.shields.io/pypi/v/hyccup?label=PyPi)](https://pypi.org/project/hyccup/)
[![Python Version](https://img.shields.io/pypi/pyversions/hyccup?label=Python)](https://pypi.org/project/hyccup/)
[![Tests](https://github.com/Arkelis/hyccup/actions/workflows/test.yml/badge.svg)](https://github.com/Arkelis/hyccup/actions/workflows/test.yml)

Hyccup is a port of [Hiccup](https://github.com/weavejester/hiccup)
for [Hy](https://github.com/hylang/hy), a Lisp embed in Python.

It allows you to represent HTML into data structure and to dump it.

```hy
=> (import [hyccup.core [html]])
=> (html ['div {'class "my-class" 'id "my-id"} "Hello Hyccup"])
"<div class=\"my-class\" id=\"my-id\">Hello Hyccup</div>"
```

Hyccup can also be used in Python:

```pycon
>>> from hyccup.core import html
>>> html(['div', {'class': 'my-class', 'id': 'my-id'}, 'Hello Hyccup'])
'<div class="my-class" id="my-id">Hello Hyccup</div>'
```

More information in the [documentation](https://hyccup.pycolore.fr).
