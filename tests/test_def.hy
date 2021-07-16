(import inspect)

(require [hyccup.defmacros [defhtml defelem]])


(defclass TestDefHtmlMacro []
  (defn test-basic-html-function [self]
    (defhtml basic-fn [x] ['span x])
    (assert (= (basic-fn "foo") "<span>foo</span>")))

  (defn test-html-fn-with-docstring [self]
    (defhtml two-params [x y]
      "Some docstring"
      ["span" x ["div" y]])
    (assert (= (two-params "foo" "bar")
               "<span>foo<div>bar</div></span>")))
  
  (defn test-html-several-elements [self]
    (defhtml third [x y]
      "Some docstring"
      (setv dummy "someval")
      #*(gfor i (range x y) ["p" i]))
    (assert (= (third 1 3)
               "<p>1</p><p>2</p>"))))


(defclass TestDefElemMacro []
  (defn test-basic [self]
    (defelem two-args [a b]
      [b a 3])
    (assert (= (two-args 0 1) [1 0 3]))
    (assert (= (two-args 0 1 {'foo "bar"}) [1 {'foo "bar"} 0 3])))
  
  (defn test-recursive [self]
    (defelem rec [a]
      (if (< a 1) [a (+ a 1)] (rec (- a 1))))
    
    (assert (= (rec 4) [0 1]))
    (assert (= (rec 4 {'foo "bar"}) [0 {'foo "bar"} 1])))
  
  (defn test-merge-attrs [self]
    (defelem with-map [[a 1] [b 2]]
      [a {'foo "bar"} b])
    
    (assert (= (with-map) [1 {'foo "bar"} 2]))
    (assert (= (with-map :attrs-map {'a "b"}) [1 {'a "b" 'foo "bar"} 2]))
    (assert (= (with-map 1 2) [1 {'foo "bar"} 2]))
    (assert (= (with-map 1 2 {'a "b"}) [1 {'a "b" 'foo "bar"} 2])))

  (defn test-preserve-special-attrs [self]
    (defelem some-func [[a 1] [b 2]]
      "some func's docstring"
      [a b])
    
    (assert (= some-func.__name__ "some_func"))
    (assert (= (str (inspect.signature some-func)) "(a=1, b=2, attrs_map=None)"))
    (assert (= some-func.__doc__ "some func's docstring\n\nLast optional positional parameter added by 'defelem' macro:\na dict of xml attributes to be added to the element."))))

;; TODO: tests with type hints
