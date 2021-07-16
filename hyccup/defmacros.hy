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
          (in (get arg 0) ['unpack-mapping 'unpack-iterable])) True]
    [True False]))


(defmacro defelem [name #* fbody]
  (setv argslist (first fbody)
        unpkmapindex (as-> (filter stararg? (enumerate argslist)) it
                           (try (first it) (except [StopIteration] [None None]))
                           (get it 0))
        argslist (if (not (is None unpkmapindex))
                   [#* (cut argslist unpkmapindex) ['attrs-map None] (cut argslist unpkmapindex None)]
                   [#* argslist ['attrs-map None]])
        fbody (list (rest fbody)))
  (setv last-arg-docstring 
    (+ "\n\nLast optional positional parameter added by 'defelem' macro:\n"
       "a dict of xml attributes to be added to the element."))
  (if (isinstance (first fbody) str)
    (setv docstring (+ (first fbody) last-arg-docstring)
          fbody (cut fbody 1 None))
    (setv docstring last-arg-docstring))
  `(defn ~name ~argslist
    ~docstring
    (import [toolz [first second last merge keymap]])
    (setv raw-result (do ~@fbody)
          args ~argslist)
    (if attrs-map
      (do
        (setv [tag #* body] raw-result)
        (if (and body (isinstance (first body) dict))
          [tag (merge (first body) attrs-map) #*(rest body)]
          [tag attrs-map #*body]))
      raw-result)))
