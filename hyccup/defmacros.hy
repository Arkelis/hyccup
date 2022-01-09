(require hyrule.control [unless])

(import functools
        inspect [signature]
        hyrule.iterables [rest]
        toolz [first second merge]
        hyccup.core [html])


(defmacro defhtml [options name #* fbody]
  "Define a function passing its output to ``html`` implicitely.
  
  HTML Options can be passed as a dict between function name and its arguments
  list.
  "
  (unless (isinstance options hy.models.Dict)
    (setv fbody (+ (, name) fbody)
          name options
          options {}))
  (if (isinstance (second fbody) str) 
    (setv head (cut fbody 2)
          body (cut fbody 2 None))
    (setv head (cut fbody 1)
          body (rest fbody)))
  `(defn ~name ~@head
    (import hyccup.core [html]
            toolz [keymap])
    (html (do ~@body) #** (keymap str ~options))))


(defmacro defelem [name #* fbody]
  "Define a HTML element.
  
  Add to the function signature a first optional dictionary argument.
  This dictionary will be merged with attributes of the returned element.
  "
  (setv argslist (first fbody)
        has-docstring (isinstance (second fbody) str) 
        first-attr-docstring ":param attrs-map: an optional dict of HTML/XML attributes."
        docstring (if has-docstring (second fbody) "")
        fbody (if has-docstring (cut fbody 2 None) (cut fbody 1 None)))
  `(do
    (import
      hyccup.util [multimethod]
      hyrule.iterables [rest]
      toolz [first merge])
    #@(multimethod
    (defn ~name ~argslist
      ~docstring
      ~@fbody))
    #@(multimethod
    (defn ~name [^dict attrs-map #* args #** kwargs]
      ~docstring
      (setv raw-result (~name #* args #** kwargs))
      (if attrs-map
        (do
          (setv [tag #* body] raw-result)
          (if (and body (isinstance (first body) dict))
            [tag (merge (first body) attrs-map) #*(rest body)]
            [tag attrs-map #*body]))
        raw-result)))))
