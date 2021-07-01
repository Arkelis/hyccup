(import [hyccup.compiler [compile-exp]])

(defn html [content]
  (compile-exp content))
