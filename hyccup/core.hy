(import [hyccup.compiler [compile-exp]]
        [hy.models [Keyword]])

(defn html [#* content [mode "xhtml"]]
  (if (coll? (first content))
    (.join "" (map (fn [el] (compile-exp el mode))
                   content))
    (compile-exp content mode)))
