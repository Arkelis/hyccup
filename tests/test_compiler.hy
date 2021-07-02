(import [hyccup.core [html]])

(defn test-compiler []
  (assert (= (html [:div {:test 1} "coucou"]) "<div test=\"1\">coucou</div>"))
  (assert (= (html [:div "coucou"]) "<div>coucou</div>"))
  (assert (= (html [:div {:test 1}]) "<div test=\"1\"></div>"))
  (assert (= (html [:div]) "<div></div>"))
  (assert (= (html ["div" {:test 1} "hello"]) "<div test=\"1\">hello</div>"))
  (assert (= (html [:div [:div]]) "<div><div></div></div>"))
  (assert (= (html [:meta {:charset "UTF-8"}]) "<meta charset=\"UTF-8\">"))
  (assert (= (html [:div#an-id "text"]) "<div id=\"an-id\">text</div>")))


