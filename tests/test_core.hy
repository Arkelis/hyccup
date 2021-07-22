;; Adapted from the test suite of Hiccup maintained by James Reeves
;; https://github.com/weavejester/hiccup

"""Tests for hyccup.core module"""

(import [hyccup.core [html raw]]
        [hyccup.util [RawStr]]
        pytest)

(require [hy.contrib.walk [let]])


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
  (assert (= (html ['body (iter [['p] ['br]])]) "<body><p></p><br /></body>"))
  (assert (= (html ['p "a"] ['p "b"]) "<p>a</p><p>b</p>"))
  (assert (= (html (iter [['p "a"] ['p "b"]])) "<p>a</p><p>b</p>"))
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

  (defn test-optimized-forms [self]
    (assert (= (html ["ul" #* (gfor n (range 3) ["li" n])])
               "<ul><li>0</li><li>1</li><li>2</li></ul>"))
    (assert (= (html ["div" (if True
                              ["span" "foo"]
                              ["span" "bar"])])
               "<div><span>foo</span></div>"))))


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

(defclass TestEscaping []
  (defn test-literals [self]
    (assert (= (html "<>") "&lt;&gt;"))
    (assert (= (html '<>) "&lt;&gt;"))
    (assert (= (html (str "<>")) "&lt;&gt;"))
    (assert (= (html 1) "1"))
    (assert (= (html (+ 1 1)) "2"))

    ;; we keep Python string repr
    (assert (= (html {"<a>" "<b>"}) "{&apos;&lt;a&gt;&apos;: &apos;&lt;b&gt;&apos;}"))
    (assert (= (html #{"<>"}) "{&apos;&lt;&gt;&apos;}")))

  (defn test-non-literals [self]
    (assert (= (html ['p "<foo>"] ['p "<bar>"])
               "<p>&lt;foo&gt;</p><p>&lt;bar&gt;</p>"))
    (assert (= (do (setv x "<foo>") (html x)) "&lt;foo&gt;")))

  (defn test-forms [self]
    (assert (= (html (if True "<foo>" "<bar>")) "&lt;foo&gt;"))
    (assert (= (html #* (gfor x ["<foo>"] x)) "&lt;foo&gt;")))

  (defn test-elements [self]
    (assert (= (html ['p "<>"]) "<p>&lt;&gt;</p>"))
    (assert (= (html ['p '<>]) "<p>&lt;&gt;</p>"))
    (assert (= (html ['p {} {"<foo>" "<bar>"}])
               "<p>{&apos;&lt;foo&gt;&apos;: &apos;&lt;bar&gt;&apos;}</p>"))
    (assert (= (html ['p {} #{"<foo>"}])
               "<p>{&apos;&lt;foo&gt;&apos;}</p>"))
    (assert (= (html ['p {'class "<\">"}])
               "<p class=\"&lt;&quot;&gt;\"></p>"))
    (assert (= (html ['p {'class ["<\">"]}])
               "<p class=\"&lt;&quot;&gt;\"></p>"))
    (assert (= (html ['ul ['li "<foo>"]])
               "<ul><li>&lt;foo&gt;</li></ul>")))

  (defn test-raw-strings-not-escaped [self]
    (assert (= (html (raw "<foo>")) "<foo>"))
    (assert (= (html ['p (raw "<foo>")]) "<p><foo></p>"))
    (assert (= (html (html ['p "<>"])) "<p>&lt;&gt;</p>"))
    (assert (= (html ['ul (html ['li "<>"])]) "<ul><li>&lt;&gt;</li></ul>")))

  (defn test-escaping-mode [self]
    (assert (= (html ['p "<>"] :escape-strings True) "<p>&lt;&gt;</p>"))
    (assert (= (html ['p "<>"] :escape-strings False) "<p><></p>"))
    (let [x ['p "<>"]]
      (assert (= (html x :escape-strings True) "<p>&lt;&gt;</p>"))
      (assert (= (html x :escape-strings False) "<p><></p>")))
    (assert (= (html ['p (raw "<>")] :escape-strings True)
           "<p><></p>"))
    (assert (= (html ['p (raw "<>")] :escape-strings False)
           "<p><></p>")))

  (defn test-attributes-always-escaped [self]
    (assert (= (html ['p {'class "<>"}] :escape-strings True)
           "<p class=\"&lt;&gt;\"></p>"))
    (assert (= (html ['p {'class "<>"}] :escape-strings False)
           "<p class=\"&lt;&gt;\"></p>"))))


(defn test-raw-string []
  (assert (is (type (raw "a str")) RawStr))
  (assert (= (raw "a str") "a str"))
  (assert (= (raw None) ""))
  (assert (= (raw ["first" "second"]) "firstsecond"))
  (assert (= (raw [["first" "second"] "third"]) "firstsecondthird")))
