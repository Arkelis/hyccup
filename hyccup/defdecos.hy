(import functools
        [inspect [signature]]
        textwrap
        [multimethod [multimethod]]
        [toolz [first merge]]
        [hyccup.core [html]])

(require [hy.contrib.walk [let]])

(defn defhtml [[func None] / #** html-options]
  (if (callable func)
    (do
      #@((functools.wraps func)
      (defn wrapper [#* args #** kwargs]
        (html (func #* args #** kwargs))))
      wrapper)
    (do
      (defn deco [function]
        #@((functools.wraps function)
        (defn wrapper [#* args #** kwargs]
          (html (function #* args #** kwargs)
                #** html-options)))
        wrapper)
      deco)))


(defn eval-and-merge-attrs [attrs-map function #*args #**kwargs]
  (if attrs-map
    (let [[tag #* body] (function #*args #**kwargs)]
      (if (and body (isinstance (first body) dict))
        [tag (merge (first body) attrs-map) #*(rest body)]
        [tag attrs-map #*body]))
    (function #*args #**kwargs)))


(defn as-arg [param]
  (setv param-name param.name
        param-kind param.kind.value)
  (cond [(= param-kind 2) f"*{param-name}"]
        [(= param-kind 3) f"{param-name}={param-name}"]
        [(= param-kind 4) f"**{param-name}"]
        [True param-name]))


(defn defelem [function]
  (setv func-signature (signature function)
        str-parameters (.join ", " (map as-arg (.values func-signature.parameters)))
        str-signature (cut (str func-signature) 1 -1)
        [pos sep kw] (.partition str-signature "*")
        pos (.removesuffix pos ", ")
        sep (if sep (+ ", " sep) sep)
        new-str-signature f"({pos}, attrs_map=None{sep}{kw})"
        locals-dict {})
  #@(multimethod
    (defn wrapper [#* args #** kwargs]
      (function #* args #** kwargs)))
  #@(multimethod
    (defn wrapper [^dict attrs-map #* args #** kwargs]
      (setv raw-result (function #* args #** kwargs))
      (if attrs-map
        (do
          (setv [tag #* body] raw-result)
          (if (and body (isinstance (first body) dict))
            [tag (merge (first body) attrs-map) #*(rest body)]
            [tag attrs-map #*body]))
        raw-result)))
  (functools.update-wrapper wrapper function))
  ;; (exec
  ;;   f"def wrapper{new-str-signature}: return eval_and_merge_attrs(attrs_map, function, {str-parameters})"
  ;;   {#** (globals) #** {"function" function}}
  ;;   locals-dict)
  ;; (setv
  ;;   wrapper (:wrapper locals-dict)
  ;;   optional-arg-doc 
  ;;     (+ "\n\nLast optional positional parameter added by 'defelem' decorator:\n"
  ;;         "a dict of xml attributes to be added to the element.")
  ;;   wrapper.__doc__
  ;;     (if function.__doc__ 
  ;;       (+ function.__doc__ optional-arg-doc)
  ;;       optional-arg-doc)
  ;;   wrapper.__name__ function.__name__)
  ;; wrapper)
