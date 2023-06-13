;; Adapted from the test suite of Hiccup maintained by James Reeves
;; https://github.com/weavejester/hiccup

"""Tests for hyccup.definition module."""

(import inspect)
(import hyccup.definition [defhtml defelem])


(defclass TestDefHtml []
  (defn test-basic-html-function [self]
    (defn [defhtml] basic-fn [x] ["span" x])
    (assert (= (basic-fn "foo") "<span>foo</span>")))

  (defn test-html-fn-with-docstring [self]
    (defn [defhtml] two-params [x y]
      "Some docstring"
      ["span" x ["div" y]])
    (assert (= (two-params "foo" "bar")
               "<span>foo<div>bar</div></span>")))
  
  (defn test-html-several-elements [self]
    (defn [defhtml] third [x y]
      "Some docstring"
      (setv dummy "someval")
      (gfor i (range x y) ["p" i]))
    (assert (= (third 1 3)
               "<p>1</p><p>2</p>")))
  
  (defn test-html-mode [self]
    (defn [(defhtml :mode "html")] html-mode []
      ["p"])

    (defn [(defhtml :mode "xml")] xml-mode []
      ["p"])
    
    (assert (= (html-mode) "<p></p>"))
    (assert (= (xml-mode) "<p />"))))


(defclass TestDefElem []
  (defn test-basic [self]
    (defn [defelem] two-args [a b]
      [b a 3])
    (assert (= (two-args 0 1) [1 0 3]))
    (assert (= (two-args {"foo" "bar"} 0 1) [1 {"foo" "bar"} 0 3])))

  (defn test-starargs [self]
    (defn [defelem] positional-only [a /]
      [a])

    (assert (= (positional-only {"foo" "bar"} 1) [1 {"foo" "bar"}]))
    
    (defn [defelem] positional-and-kw-only [a / b * c]
      [a (+ b c)])

    (assert (= (positional-and-kw-only {"foo" "bar"} 1 2 :c 3)
               [1 {"foo" "bar"} 5]))
    
    (defn [defelem] var-positional [a #* args #** kwargs] 
      [a (+ (sum args) (sum (.values kwargs)))])

    (assert (= (var-positional {"foo" "bar"} 1 4 5 :b 6 :c 7)
               [1 {"foo" "bar"} 22])))
  
  (defn test-recursive [self]
    (defn [defelem] rec [a]
      (if (< a 1) [a (+ a 1)] (rec (- a 1))))
    
    (assert (= (rec 4) [0 1]))
    (assert (= (rec {"foo" "bar"} 4) [0 {"foo" "bar"} 1])))
  
  (defn test-merge-attrs [self]
    (defn [defelem] with-map [[a 1] [b 2]]
      [a {"foo" "bar"} b])
    
    (assert (= (with-map) [1 {"foo" "bar"} 2]))
    (assert (= (with-map {"a" "b"}) [1 {"a" "b" "foo" "bar"} 2]))
    (assert (= (with-map 1 2) [1 {"foo" "bar"} 2]))
    (assert (= (with-map {"a" "b"} 1 2) [1 {"a" "b" "foo" "bar"} 2])))

  (defn test-preserve-special-attrs [self]
    (defn [defelem] some-func [#^int [a 1] #^int [b 2]]
      "some func's docstring"
      [a b])
    
    (assert (= some-func.__name__ "some_func"))))


(defclass TestDefElemMethod []
  (defn test-basic [self]
    (defclass Ham []
       (defn [defelem.method] two-args [self a b]
          [b a 3]))
    (assert (= (.two-args (Ham) 0 1) [1 0 3]))
    (assert (= (.two-args (Ham) {"foo" "bar"} 0 1) [1 {"foo" "bar"} 0 3])))

  (defn test-starargs [self]
    (defclass Ham []
      (defn [defelem.method] positional-only [self a /]
        [a])
      
      (defn [defelem.method] positional-and-kw-only [self a / b * c]
        [a (+ b c)])
      
      (defn [defelem.method] var-positional [self a #* args #** kwargs] 
        [a (+ (sum args) (sum (.values kwargs)))]))

    (assert (= (.positional-only (Ham) {"foo" "bar"} 1) [1 {"foo" "bar"}]))
    (assert (= (.positional-and-kw-only (Ham) {"foo" "bar"} 1 2 :c 3)
               [1 {"foo" "bar"} 5]))
    (assert (= (.var-positional (Ham) {"foo" "bar"} 1 4 5 :b 6 :c 7)
               [1 {"foo" "bar"} 22])))
  
  (defn test-recursive [self]
    (defclass Ham []
      (defn [defelem.method] rec [self a]
        (if (< a 1) [a (+ a 1)] (self.rec (- a 1)))))
    
    (assert (= (.rec (Ham) 4) [0 1]))
    (assert (= (.rec (Ham) {"foo" "bar"} 4) [0 {"foo" "bar"} 1])))
  
  (defn test-merge-attrs [self]
    (defclass Ham []
      (defn [defelem.method] with-map [self [a 1] [b 2]]
        [a {"foo" "bar"} b]))
    
    (assert (= (.with-map (Ham)) [1 {"foo" "bar"} 2]))
    (assert (= (.with-map (Ham) {"a" "b"}) [1 {"a" "b" "foo" "bar"} 2]))
    (assert (= (.with-map (Ham) 1 2) [1 {"foo" "bar"} 2]))
    (assert (= (.with-map (Ham) {"a" "b"} 1 2) [1 {"a" "b" "foo" "bar"} 2])))

  (defn test-preserve-special-attrs [self]
    (defclass Ham []
      (defn [defelem.method] some-func [self #^int [a 1] #^int [b 2]]
        "some func's docstring"
        [a b]))
    
    (assert (= (. (Ham) some-func __name__) "some_func"))))