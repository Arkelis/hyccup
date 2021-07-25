(import functools
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


(defn defelem [function]
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
