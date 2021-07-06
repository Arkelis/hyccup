(import [hyccup.util [as-str]]
        [urllib.parse [urlparse]])

(defn test-as-str []
  (assert (= (as-str "foo") "foo"))
  (assert (= (as-str 'foo) "foo"))
  (assert (= (as-str 100) "100"))
  (assert (= (as-str 4/3) (str (float 4/3))))
  (assert (= (as-str "a" 'b 3) "ab3"))
  (assert (= (as-str (urlparse "/foo")) "/foo"))
  (assert (= (as-str (urlparse "localhost:3000/foo")) "localhost:3000/foo")))
