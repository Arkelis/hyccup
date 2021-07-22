(import threading
        [contextlib [contextmanager]]
        [functools [singledispatch]]
        [fractions [Fraction]]
        [urllib.parse [SplitResult urlsplit urlencode quote-plus]] 
        [hy.models [Keyword Symbol]])


(setv local-data (.local threading)
      local-data.encoding None
      local-data.base-url "")


(defn to-str [obj]
  (cond
    [(isinstance obj Fraction) (-> obj (float) (str))]
    [(isinstance obj SplitResult) (make-url obj)]
    [True (str obj)]))

(defn as-str [#* obj]
  (.join "" (map to-str obj)))

(defn escape-html [string mode escape-strings]
  "Change special characters into HTML character entities."
  (if escape-strings
    (-> string
        (.replace "&"  "&amp;")
        (.replace "<"  "&lt;")
        (.replace ">"  "&gt;")
        (.replace "\"" "&quot;")
        (.replace "'" (if (= (str mode) "sgml") "&#39;" "&apos;")))
    string))


(defclass RawStr [str]
  (setv __slots__ (,))

  (with-decorator classmethod
    (defn from-obj-or-iterable [cls obj]
      (cond
        [(is None obj) (RawStr "")]
        [(coll? obj) (RawStr (+ #* (map (. RawStr from-obj-or-iterable) obj)))]
        [True (RawStr obj)]))))


;; URL

(with-decorator singledispatch
  (defn url-encode [obj]
    (quote-plus obj)))
    
(with-decorator url-encode.register
  (defn _ [^dict obj]
    (urlencode obj :encoding local-data.encoding)))

(with-decorator contextmanager
  (defn encoding [enc]
    (try
      (yield (setv local-data.encoding enc))
    (finally
      (setv local-data.encoding None)))))

(do
  (with-decorator singledispatch
    (defn to-uri [obj]
      (urlsplit (str obj))))
  (with-decorator to-uri.register
    (defn _ [^str obj]
      (urlsplit obj)))
  (with-decorator to-uri.register
    (defn _ [^SplitResult obj]
      obj)))

(defn make-url [split-result]
  (if (or split-result.netloc
          (is None split-result.path)
          (not (.startswith split-result.path "/")))
    (.geturl split-result)
    (as-> local-data.base-url it
          (.removesuffix it "/")
          (+ it split-result.path)
          (._replace split-result :path it)
          (.geturl it))))

(with-decorator contextmanager
 (defn base-url [url]
   (try
     (yield (setv local-data.base-url url))
   (finally
     (setv local-data.base-url "")))))

(defn url [#* parts #** query-params]
  (to-uri (+ (.join "" parts)
             (url-encode query-params))))


;; Iterable utils

(defn empty? [coll]
  (= (len coll) 0))
