(import functools
        [inspect [signature]]
        [toolz [first second merge]]
        [hyccup.core [html]])


(defmacro defhtml [name #* fbody]
  (if (isinstance (second fbody) str) 
    (setv head (cut fbody 2)
          body (cut fbody 2 None))
    (setv head (cut fbody 1)
          body (rest fbody)))
  `(defn ~name ~@head
    (import [hyccup.core [html]])
    (html (do ~@body))))


(defn stararg? [index-and-arg]
  (setv arg (get index-and-arg 1))
  (cond
    [(= arg '*) True]
    [(and (coll? arg)
          (= (first arg) 'annotate))
     False]
    [(and (coll? arg) 
          (in (first arg) ['unpack-mapping 'unpack-iterable])) 
     True]
    [True False]))


(defmacro defelem [name #* fbody]
  (setv argslist (first fbody)
        has-docstring (isinstance (second fbody) str) 
        first-attr-docstring "First optional attribute: a dict of HTML/XML attributes."
        docstring 
          (if has-docstring
            (+ (second fbody) "\n\n" first-attr-docstring)
            first-attr-docstring)
        fbody (if has-docstring (cut fbody 2 None) (cut fbody 1 None)))
  `(do
    (import
      [multimethod [multimethod]] 
      [toolz [first merge]])
    #@(multimethod
    (defn ~name ~argslist
      ~docstring
      ~@fbody))
    #@(multimethod
    (defn ~name [^dict attrs-map #* args #** kwargs]
      (setv raw-result (~name #* args #** kwargs))
      (if attrs-map
        (do
          (setv [tag #* body] raw-result)
          (if (and body (isinstance (first body) dict))
            [tag (merge (first body) attrs-map) #*(rest body)]
            [tag attrs-map #*body]))
        raw-result)))))
