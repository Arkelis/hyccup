(import [hyccup.compiler [compile-exp]])

(defn html [content]
  (print (compile-exp content))
  (compile-exp content))
