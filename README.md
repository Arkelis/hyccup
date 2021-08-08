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

Hyccup can also be used in Python:

```pycon
>>> from hyccup.core import html
>>> html(['div', {'class': 'my-class', 'id': 'my-id'}, 'Hello Hyccup'])
'<div class="my-class" id="my-id">Hello Hyccup</div>'
```

More information in the [documentation](https://arkelis.github.io/hyccup).
