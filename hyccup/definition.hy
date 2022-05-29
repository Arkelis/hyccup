(require hyrule [unless])

(import functools
        inspect [signature]
        hyrule [rest]
        toolz [first second merge]
        hyccup.util [multimethod]
        hyccup.core [html])


(defn defhtml [[func None] / #** html-options]
  "Decorate a function for passing its result to ``html``.
  
  Take HTML options as keyword arguments.
  "
  (if (callable func)
    (do
      (defn [(functools.wraps func)] wrapper [#* args #** kwargs]
        (html (func #* args #** kwargs)))
      wrapper)
    (do
      (defn deco [function]
        (defn [(functools.wraps function)] wrapper [#* args #** kwargs]
          (html (function #* args #** kwargs)
                #** html-options))
        wrapper)
      deco)))


(defn defelem [function]
  "Decorate a function for defining elements using multimethod.
  
  The returned object is a callable with two signature:
  
  * The original signature of the function
  * The original signature with as first parameter a dict of attributes. This
    will be merged with attributes of the returned element.
  "
  (defn [multimethod] wrapper [#* args #** kwargs]
    (function #* args #** kwargs))
  (defn [multimethod] wrapper [#^dict attrs-map #* args #** kwargs]
    (setv raw-result (function #* args #** kwargs))
    (if attrs-map
      (do
        (setv [tag #* body] raw-result)
        (if (and body (isinstance (first body) dict))
          [tag (merge (first body) attrs-map) #*(rest body)]
          [tag attrs-map #*body]))
      raw-result))
  (functools.update-wrapper wrapper function))


(defmacro defhtml [options name #* fbody]
  "Define a function passing its output to ``html`` implicitely.
  
  HTML Options can be passed as a dict between function name and its arguments
  list.
  "
  (unless (isinstance options hy.models.Dict)
    (setv fbody (+ #(name) fbody)
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
      hyrule [rest]
      toolz [first merge])
    (defn [multimethod] ~name ~argslist
      ~docstring
      ~@fbody)
    (defn [multimethod] ~name [#^dict attrs-map #* args #** kwargs]
      ~docstring
      (setv raw-result (~name #* args #** kwargs))
      (if attrs-map
        (do
          (setv [tag #* body] raw-result)
          (if (and body (isinstance (first body) dict))
            [tag (merge (first body) attrs-map) #*(rest body)]
            [tag attrs-map #*body]))
        raw-result))))
