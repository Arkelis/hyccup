"""Tests for hyccup.core module"""

(import [hyccup.core [html]]
        pytest)

;; See https://github.com/weavejester/hiccup/blob/master/test/hiccup/core_test.clj
;; Taken from the test suite of Hiccup maintained by James Reeves

(defn test-tag-name []
  (assert (= (html ["div"]) "<div></div>"))
  (assert (= (html ['div]) "<div></div>")))

(defn test-tag-name-syntax []
  (assert (= (html ['div#foo]) "<div id=\"foo\"></div>"))
  (assert (= (html ['div.foo]) "<div class=\"foo\"></div>"))
  (assert (= (html ['div.foo (+ "bar" "baz")])
             "<div class=\"foo\">barbaz</div>"))
  (assert (= (html ['div.a.b]) "<div class=\"a b\"></div>"))
  (assert (= (html ['div.a.b.c]) "<div class=\"a b c\"></div>"))
  (assert (= (html ['div#foo.bar.baz])
             "<div class=\"bar baz\" id=\"foo\"></div>")))

(defn test-empty-tags []
  (assert (= (html ['div]) "<div></div>"))
  (assert (= (html ['h1]) "<h1></h1>"))
  (assert (= (html ['script]) "<script></script>"))
  (assert (= (html ['text]) "<text></text>"))
  (assert (= (html ['a]) "<a></a>"))
  (assert (= (html ['iframe]) "<iframe></iframe>"))
  (assert (= (html ['title]) "<title></title>"))
  (assert (= (html ['section]) "<section></section>"))
  (assert (= (html ['select]) "<select></select>"))
  (assert (= (html ['object]) "<object></object>"))
  (assert (= (html ['video]) "<video></video>")))

(defn test-void-tags []
  (assert (= (html ['br]) "<br />"))
  (assert (= (html ['link]) "<link />"))
  (assert (= (html ['colgroup {'span 2}]) "<colgroup span=\"2\"></colgroup>"))
  (assert (= (html ['colgroup ['col]]) "<colgroup><col /></colgroup>")))

(defn test-contents []
  (assert (= (html ['text "Lorem Ipsum"]) "<text>Lorem Ipsum</text>"))
  (assert (= (html ['body "foo" "bar"]) "<body>foobar</body>"))
  (assert (= (html ['body ['p] ['br]]) "<body><p></p><br /></body>"))
  (assert (= (html ['p "a"] ['p "b"]) "<p>a</p><p>b</p>"))
  (assert (= (html ['div 'foo]) "<div>foo</div>"))
  (with [(pytest.raises TypeError)]
    (html [['p "a"] ['p "b"]]) "<p>a</p><p>b</p>")
  (assert (= (html ['div ['p]]) "<div><p></p></div>"))
  (assert (= (html ['div ['b]]) "<div><b></b></div>"))
  (assert (= (html ['p ['span ['a "foo"]]])
             "<p><span><a>foo</a></span></p>")))

(defn test-attributes []
  (assert (= (html ['xml {}]) "<xml></xml>"))
  (assert (= (html ['img {"id" "foo"}]) "<img id=\"foo\" />"))
  (assert (= (html ['img {'id "foo"}]) "<img id=\"foo\" />"))
  (assert (= (html ['xml {'b "2" "c" "3"}])
          "<xml b=\"2\" c=\"3\"></xml>"))
  (assert (= (html ['div {"id" "\""}]) "<div id=\"&quot;\"></div>"))
  (assert (= (html ['input {"type" "checkbox" "checked" True}])
          "<input checked=\"checked\" type=\"checkbox\" />"))
  (assert (= (html ['input {"type" "checkbox" "checked" False}])
          "<input type=\"checkbox\" />"))
  (assert (= (html ['span {"class" None} "foo"])
          "<span>foo</span>"))
  (assert (= (html ['div.foo {"class" "bar"} "baz"])
          "<div class=\"foo bar\">baz</div>"))
  (assert (= (html ['div#bar.foo {"id" "baq"} "baz"])
          "<div class=\"foo\" id=\"baq\">baz</div>"))
  (assert (= (html ['div.foo {"class" ["bar"]} "baz"])
          "<div class=\"foo bar\">baz</div>"))
  (assert (= (html ['div.foo {"class" ['bar]} "baz"])
          "<div class=\"foo bar\">baz</div>"))
  (assert (= (html ['div.foo {"class" ['bar "box"]} "baz"])
          "<div class=\"foo bar box\">baz</div>"))
  (assert (= (html ['div.foo {"class" ["bar" "box"]} "baz"])
          "<div class=\"foo bar box\">baz</div>"))
  (assert (= (html ['div.foo {"class" ['bar 'box]} "baz"])
          "<div class=\"foo bar box\">baz</div>")))


(defclass TestCompiledTags []
  (defn test-content-var [self]
    (assert (= (do (setv x "foo") (html ["span" x])) "<span>foo</span>")))
  
  (defn test-content-exp [self]
    (assert (= (html ["span" (str (+ 1 1))]) "<span>2</span>"))
    (assert (= (html ["span" (:foo {"foo" "bar"})]) "<span>bar</span>")))

  (defn test-attributes-vars [self]
    (setv x "foo")
    (assert (= (html ["xml" {"x" x}]) "<xml x=\"foo\"></xml>"))
    (assert (= (html ["xml" {x "x"}]) "<xml foo=\"x\"></xml>"))
    (assert (= (html ["xml" {'x x} "bar"]) "<xml x=\"foo\">bar</xml>")))

  (defn test-attributes-exp [self]
    (assert (= (html ["img" {'src (+ "/foo" "/bar")}])
               "<img src=\"/foo/bar\" />"))
    (assert (= (html ['div {"id" (+ "a" "b")} (str "foo")])
               "<div id=\"ab\">foo</div>")))

;;   (testing "type hints"
;;     (let [string "x"]
;;       (is (= (html [:span ^String string]) "<span>x</span>"))))

  (defn test-optimized-forms [self]
    (assert (= (html ["ul" #* (gfor n (range 3) ["li" n])])
               "<ul><li>0</li><li>1</li><li>2</li></ul>"))
    (assert (= (html ["div" (if True
                              ["span" "foo"]
                              ["span" "bar"])])
               "<div><span>foo</span></div>"))))

;;   (testing "values are evaluated only once"
;;     (let [times-called (atom 0)
;;           foo #(swap! times-called inc)]
;;       (html [:div (foo)])
;;       (is (= @times-called 1))))
;;   (testing "defer evaluation of non-literal class names when combined with tag classes"
;;     (let [x "attr-class"]
;;       (is  (= (html [:div.tag-class {:class x}])
;;               "<div class=\"tag-class attr-class\"></div>")))))


(defclass TestRenderModes []
  (defn test-closed-tags [self]
    (assert (= (html ['p] ['br]) "<p></p><br />"))
    (assert (= (html ["p"] ['br] :mode "xhtml") "<p></p><br />"))
    (assert (= (html ["p"] ['br] :mode "html") "<p></p><br>"))
    (assert (= (html ["p"] ['br] :mode "xml") "<p /><br />"))
    (assert (= (html ["p"] ['br] :mode "sgml") "<p><br>")))
  
  (defn test-boolean-attributes [self]
    (assert (= (html ["input" {"type" "checkbox" "checked" True}] :mode "xml")
               "<input checked=\"checked\" type=\"checkbox\" />"))
    (assert (= (html ["input" {"type" "checkbox" "checked" True}] :mode "sgml")
               "<input checked type=\"checkbox\">"))))

  ;; Purpose of this test to clarify
  ;; (defn test-laziness-and-binding-scope [self]
  ;;   (assert (= (html ["html" ["link"] #* [["link"]]] :mode "sgml")
  ;;              "<html><link><link></html>"))))
