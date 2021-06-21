(import [hyccup.compiler [compile-exp]])

(defn test-compiler []
  (assert (= (compile-exp [:div {:test 1} "coucou"]) "<div test=\"1\">coucou</div>"))
  (assert (= (compile-exp [:div "coucou"]) "<div>coucou</div>"))
  (assert (= (compile-exp [:div {:test 1}]) "<div test=\"1\"></div>"))
  (assert (= (compile-exp [:div]) "<div></div>"))
  (assert (= (compile-exp ["div" {:test 1} "hello"]) "<div test=\"1\">hello</div>"))
  (assert (= (compile-exp [:div [:div]]) "<div><div></div></div>")))


