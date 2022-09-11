;; Adapted from the test suite of Hiccup maintained by James Reeves
;; https://github.com/weavejester/hiccup

"""Tests for hyccup.page module."""

(import hyccup.page [html4 xhtml html5 include-css include-js]
        hyccup.util :as util)

(defn test-html4 []
  (assert (= (html4 ["body" ["p" "Hello" ["br"] "World"]])
             (+ "<!DOCTYPE html PUBLIC \"-//W3C//DTD HTML 4.01//EN\" "
                "\"http://www.w3.org/TR/html4/strict.dtd\">\n"
                "<html><body><p>Hello<br>World</p></body></html>"))))

(defn test-xhtml []
  (assert (= (xhtml ["body" ["p" "Hello" ["br"] "World"]])
             (+ "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n"
                "<!DOCTYPE html PUBLIC \"-//W3C//DTD XHTML 1.0 Strict//EN\" "
                "\"http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd\">\n"
                "<html xmlns=\"http://www.w3.org/1999/xhtml\">"
                "<body><p>Hello<br />World</p></body></html>")))
  (assert (= (xhtml ["body" ["p" "Hello" ["br"] "World"]]
                    :lang "en")
             (+ "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n"
                "<!DOCTYPE html PUBLIC \"-//W3C//DTD XHTML 1.0 Strict//EN\" "
                "\"http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd\">\n"
                "<html lang=\"en\" xml:lang=\"en\" xmlns=\"http://www.w3.org/1999/xhtml\">"
                "<body><p>Hello<br />World</p></body></html>")))
  (assert (= (xhtml ["body" "Hello World"] :encoding "ISO-8859-1" :lang "en")
             (+ "<?xml version=\"1.0\" encoding=\"ISO-8859-1\"?>\n"
                "<!DOCTYPE html PUBLIC \"-//W3C//DTD XHTML 1.0 Strict//EN\" "
                "\"http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd\">\n"
                "<html lang=\"en\" xml:lang=\"en\" xmlns=\"http://www.w3.org/1999/xhtml\">"
                "<body>Hello World</body></html>"))))

(defclass TestHTML5 []
  (defn test-html-mode [self]
    (assert (= (html5 ["body" ["p" "Hello" ["br"] "World"]])
               "<!DOCTYPE html>\n<html><body><p>Hello<br>World</p></body></html>"))
    (assert (= (html5 ["body" "Hello World"] :lang "en")
               "<!DOCTYPE html>\n<html lang=\"en\"><body>Hello World</body></html>"))
    (assert (= (html5 {"prefix" "og: http://ogp.me/ns#"} ["body" "Hello World"])
               (+ "<!DOCTYPE html>\n"
                  "<html prefix=\"og: http://ogp.me/ns#\">"
                  "<body>Hello World</body></html>")))
    (assert (= (html5 {"prefix" "og: http://ogp.me/ns#"} ["body" "Hello World"]
                     :lang "en")
               (+ "<!DOCTYPE html>\n"
                  "<html lang=\"en\" prefix=\"og: http://ogp.me/ns#\">"
                  "<body>Hello World</body></html>"))))
  
  (defn test-xml-mode [self]
    (assert (= (html5 ["body" ["p" "Hello" ["br"] "World"]] :xml True)
               (+ "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n"
                  "<!DOCTYPE html>\n<html xmlns=\"http://www.w3.org/1999/xhtml\">"
                  "<body><p>Hello<br />World</p></body></html>")))
    (assert (= (html5 ["body" "Hello World"] :xml True :lang "en")
               (+ "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n"
                  "<!DOCTYPE html>\n"
                  "<html lang=\"en\" xml:lang=\"en\" xmlns=\"http://www.w3.org/1999/xhtml\">"
                  "<body>Hello World</body></html>")))
    (assert (= (html5 {"xml:og" "http://ogp.me/ns#"}
                      ['body "Hello World"]
                      :xml True)
               (+ "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n"
                  "<!DOCTYPE html>\n"
                  "<html xml:og=\"http://ogp.me/ns#\" xmlns=\"http://www.w3.org/1999/xhtml\">"
                  "<body>Hello World</body></html>")))    
    (assert (= (html5 {"xml:og" "http://ogp.me/ns#"} ["body" "Hello World"]
                  :xml True :lang "en")
               (+ "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n"
                  "<!DOCTYPE html>\n"
                  "<html lang=\"en\" xml:lang=\"en\" xml:og=\"http://ogp.me/ns#\" xmlns=\"http://www.w3.org/1999/xhtml\">"
                  "<body>Hello World</body></html>")))))

(defn test-include-js []
  (assert (= (include-js "foo.js")
             [["script" {"type" "text/javascript" "src" (util.to-uri "foo.js")}]]))
  (assert (= (include-js "foo.js" "bar.js")
             [["script" {"type" "text/javascript" "src" (util.to-uri "foo.js")}]
              ["script" {"type" "text/javascript" "src" (util.to-uri "bar.js")}]])))

(defn test-include-css []
  (assert (= (include-css "foo.css")
             [["link" {"type" "text/css" "href" (util.to-uri "foo.css") "rel" "stylesheet"}]]))
  (assert (= (include-css "foo.css" "bar.css")
             [["link" {"type" "text/css" "href" (util.to-uri "foo.css") "rel" "stylesheet"}]
              ["link" {"type" "text/css" "href" (util.to-uri "bar.css") "rel" "stylesheet"}]])))
