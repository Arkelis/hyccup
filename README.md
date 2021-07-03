# Hyccup

[![Tests](https://github.com/Arkelis/hyccup/actions/workflows/test.yml/badge.svg)](https://github.com/Arkelis/hyccup/actions/workflows/test.yml)

Hyccup is a port of [Hiccup](https://github.com/weavejester/hiccup)
for [Hy](https://github.com/hylang/hy), a LISP embed in Python.

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

### Lists

The following call is valid in Hiccup:

```clj
(html (list [:p "some text"] [:p "another p"]))
```

In Hyccup, just chain the elements or use unpacking (as we already use lists to
represent elements, where Hiccup use Clojure vectors).

```hy
(html [:p "some text"] [:p "another p"]))
(html #* [[:p "some text"] [:p "another p"]]))
(html (unpack-iterable [[:p "some text"] [:p "another p"]])))
```

<!-- ## Use Hyccup with web frameworks

### Django

### Flask -->
