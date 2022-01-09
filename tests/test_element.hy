;; Adapted from the test suite of Hiccup maintained by James Reeves
;; https://github.com/weavejester/hiccup

"""Tests for hyccup.element module."""

(import urllib.parse
        hyccup.core [html]
        hyccup.element *)


(defn test-javascript-tag []
  (assert (= (javascript-tag "alert('hello');")
         ['script {'type "text/javascript"}
          "//<![CDATA[\nalert('hello');\n//]]>"])))

(defn test-link-to []
  (assert (= (link-to "/")
         ['a {'href (urllib.parse.urlsplit "/")}]))
  (assert (= (link-to "/" "foo")
         ['a {'href (urllib.parse.urlsplit "/")} "foo"]))
  (assert (= (link-to "/" "foo" "bar")
         ['a {'href (urllib.parse.urlsplit "/")} "foo" "bar"])))

(defn test-mail-to []
  (print (mail-to "foo@example.com" "foo"))
  (assert (= (mail-to "foo@example.com")
         ['a {'href "mailto:foo@example.com"} "foo@example.com"]))
  (assert (= (mail-to "foo@example.com" "foo")
         ['a {'href "mailto:foo@example.com"} "foo"])))

(defn test-unordered-list []
  (assert (= (html (unordered-list ["foo" "bar" "baz"]))
             "<ul><li>foo</li><li>bar</li><li>baz</li></ul>")))

(defn test-ordered-list []
  (assert (= (html (ordered-list ["foo" "bar" "baz"]))
             "<ol><li>foo</li><li>bar</li><li>baz</li></ol>")))
