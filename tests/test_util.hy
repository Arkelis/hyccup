;; Adapted from the test suite of Hiccup maintained by James Reeves
;; https://github.com/weavejester/hiccup

"""Tests for hyccup.util module."""

(import fractions [Fraction]
        hyccup.util [as-str to-str to-uri base-url encoding url-encode url]
        urllib.parse [urlsplit])

(defn test-as-str []
  (assert (= (as-str "foo") "foo"))
  (assert (= (as-str 'foo) "foo"))
  (assert (= (as-str 100) "100"))
  (let [frac (Fraction 4 3)] (assert (= (as-str frac) (str (float frac)))))
  (assert (= (as-str "a" 'b 3) "ab3"))
  (assert (= (as-str (urlsplit "/foo")) "/foo"))
  (assert (= (as-str (urlsplit "localhost:3000/foo")) "localhost:3000/foo")))


(defclass TestToURI []
 (defn test-with-no-base-url [self]
    (assert (= (to-str (to-uri "foo")) "foo"))
    (assert (= (to-str (to-uri "/foo/bar")) "/foo/bar"))
    (assert (= (to-str (to-uri "/foo#bar")) "/foo#bar")))
  (defn test-with-base-url [self]
    (with [b (base-url "/foo")]
      (assert (= (to-str (b.to-uri "/bar")) "/foo/bar"))
      (assert (= (to-str (b.to-uri "http://example.com")) "http://example.com"))
      (assert (= (to-str (b.to-uri "https://example.com/bar")) "https://example.com/bar"))
      (assert (= (to-str (b.to-uri "bar")) "bar"))
      (assert (= (to-str (b.to-uri "../bar")) "../bar"))
      (assert (= (to-str (b.to-uri "//example.com/bar")) "//example.com/bar"))))
  (defn test-base-url-for-root-context [self]
    (with [b (base-url "/")]
      (assert (= (to-str (b.to-uri "/bar")) "/bar"))
      (assert (= (to-str (b.to-uri "http://example.com")) "http://example.com"))
      (assert (= (to-str (b.to-uri "https://example.com/bar")) "https://example.com/bar"))
      (assert (= (to-str (b.to-uri "bar")) "bar"))
      (assert (= (to-str (b.to-uri "../bar")) "../bar"))
      (assert (= (to-str (b.to-uri "//example.com/bar")) "//example.com/bar"))))
  (defn test-base-url-containing-trailing-slash [self]
    (with [b (base-url "/foo/")]
      (assert (= (to-str (b.to-uri "/bar")) "/foo/bar"))
      (assert (= (to-str (b.to-uri "http://example.com")) "http://example.com"))
      (assert (= (to-str (b.to-uri "https://example.com/bar")) "https://example.com/bar"))
      (assert (= (to-str (b.to-uri "bar")) "bar"))
      (assert (= (to-str (b.to-uri "../bar")) "../bar"))
      (assert (= (to-str (b.to-uri "//example.com/bar")) "//example.com/bar")))))

(defclass TestURLEncode []
  (defn test-strings [self]
    (assert (= (url-encode "a") "a"))
    (assert (= (url-encode "a b") "a+b"))
    (assert (= (url-encode "&") "%26")))
  (defn test-query-parameters [self]
    (assert (= (url-encode {"a" "b"}) "a=b"))
    (assert (= (url-encode {'a "b"}) "a=b"))
    (assert (= (url-encode {'a "b" 'c "d"}) "a=b&c=d"))
    (assert (= (url-encode {'a "&"}) "a=%26"))
    (assert (= (url-encode {'é "è"}) "%C3%A9=%C3%A8")))
  (defn test-encodings [self]
    (assert (= (with [e (encoding "UTF-8")] (e.url-encode {'iroha "いろは"}))
               "iroha=%E3%81%84%E3%82%8D%E3%81%AF"))
    (assert (= (with [e (encoding "Shift_JIS")] (e.url-encode {'iroha "いろは"}))
               "iroha=%82%A2%82%EB%82%CD"))
    (assert (= (with [e (encoding "EUC-JP")] (e.url-encode {'iroha "いろは"}))
               "iroha=%A4%A4%A4%ED%A4%CF"))
    (assert (= (with [e (encoding "ISO-2022-JP")] (e.url-encode {'iroha "いろは"}))
               "iroha=%1B%24B%24%24%24m%24O%1B%28B"))))

(defn test-url []
  (assert (= (to-str (url "/foo" "/bar" :k "v")) "/foo/bar?k=v"))
  (assert (= (to-str (with [b (base-url "/foo")] (b.url "/bar" :k "v")) "/foo/bar?k=v")))
  (assert (= (to-str (with [b (base-url "/foo" :encoding "UTF-8")] (b.url "/bar" :k "à")) "/foo/bar?k=à"))))