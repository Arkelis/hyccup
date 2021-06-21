(import [hy.models [Keyword]])

(defn to-str [obj]
  (cond
    [(instance? Keyword obj) (. obj name)]
    [True (str obj)]))
