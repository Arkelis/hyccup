(require hyrule [unless])

(import functools
        inspect [signature]
        hyrule [rest]
        toolz [first second merge]
        hyccup [html])


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


(defn _split-args [args kwargs]
  (match #(args kwargs)
    [[(dict) :as attrs-map #* others] kwargs] #(attrs-map others kwargs)
    [[] {"attrs_map" (dict) :as attrs-map  #** others}] #(attrs-map #() others)
    _ #(None args kwargs)))


(defn defelem [function]
  "Decorate a function for defining elements.
  
  The returned object is a callable with two signature:
  
  * The original signature of the function
  * The original signature with as first parameter a dict of attributes. This
    will be merged with attributes of the returned element.
  "
  (defn [(functools.wraps function)] wrapper [#* args #** kwargs]
    (let [#(attrs-map args kwargs) (_split-args args kwargs)
          raw-result (function #* args #** kwargs)]
      (if attrs-map
        (let [#(tag #* body) raw-result]
          (if (and body (isinstance (first body) dict))
            [tag (merge (first body) attrs-map) #* (rest body)]
            [tag attrs-map #*body]))
      raw-result)))
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
    (import hyccup [html]
            toolz [keymap])
    (html (do ~@body) #** (keymap str ~options))))


(defmacro defelem [name #* fbody]
  "Define a HTML element.
  
  Add to the function signature a first optional dictionary argument.
  This dictionary will be merged with attributes of the returned element.
  "
  (let [argslist (first fbody)
        has-docstring (isinstance (second fbody) str) 
        first-attr-docstring ":param attrs-map: an optional dict of HTML/XML attributes."
        docstring (if has-docstring (second fbody) "")
        fbody (if has-docstring (cut fbody 2 None) (cut fbody 1 None))]
  `(do
    (import
      hyccup.definition [_split-args])
    (defn ~name [#* args #** kwargs]
      ~docstring
      (defn get-raw-result ~argslist
        ~@fbody)
      (let [#(attrs-map args kwargs) (_split-args args kwargs)
            raw-result (get-raw-result #* args #** kwargs)]
        (if attrs-map
          (let [[tag #* body] raw-result]
            (if (and body (isinstance (get body 0) dict))
              [tag (| (get body 0) attrs-map) #*(cut body 1 None)]
              [tag attrs-map #*body]))
          raw-result))))))
