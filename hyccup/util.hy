(require hyrule [-> as->])

(import threading
        contextlib [contextmanager]
        functools [singledispatch]
        fractions [Fraction]
        urllib.parse [SplitResult urlsplit urlencode quote-plus]
        hy.models [Keyword Symbol]
        hyrule [coll?]
        multimethod)


(setv local-data (.local threading)
      local-data.encoding None
      local-data.base-url "")


(defn to-str [obj]
  "Convert any object to string.
  
  In particular:

  * Convert fraction to string of its decimal result.
  * Convert a ``url.parse.SplitResult`` object to its URL with :hy:func:`str-of-url`.
  * For any other case, convert with ``str`` constructor."
  (cond
    (isinstance obj Fraction) (-> obj (float) (str))
    (isinstance obj SplitResult) (str-of-url obj)
    True (str obj)))


(defn as-str [#* obj]
  "Convert all passed objects to string with :hy:func:`to-str`."
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
  "Raw string class, subclass of ``str``.
  
  Instances of this class are not escaped.
  "

  (setv __slots__ #())

  (defn [classmethod] from-obj-or-iterable [cls obj]
    "Produce a raw string from an object or a collection."
    (cond
      (is None obj) (RawStr "")
      (coll? obj) (RawStr (+ #* (map (. RawStr from-obj-or-iterable) obj)))
      True (RawStr obj))))


;; URL

(defn url [#* parts #** query-params]
  "Convert parts of an URL and query params to a ``url.parse.SplitResult``."
  (to-uri (+ (.join "" parts)
             (url-encode query-params))))


(defn [contextmanager] base-url [url]
  "Context manager specifying base URL for URLs.
  
  .. tab:: Hy
  
      .. code-block:: clj
      
          => (with [(base-url \"/foo\")]
          ...  (setv my-url (to-str (to-uri \"/bar\"))))
          => (print my-url)
          \"/foo/bar\"

  .. tab:: Python
  
      .. code-block::
      
          >>> with base_url('/foo'):
          ...     my_url = to_str(to_uri('/bar'))
          ...
          >>> print(my-url)
          /foo/bar
  "
  (try
    (yield (setv local-data.base-url url))
  (finally
    (setv local-data.base-url ""))))


(defn [contextmanager] encoding [enc]
  "Context manager specifying encoding.
  
  .. tab:: Hy

      .. code-block:: clj
      
          => (with [(encoding \"UTF-8\")]
          ...  (url-encode {'iroha \"いろは\"}))
          \"iroha=%E3%81%84%E3%82%8D%E3%81%AF\"
          => (with [(encoding \"ISO-2022-JP\")]
          ...  (url-encode {'iroha \"いろは\"}))
          \"iroha=%1B%24B%24%24%24m%24O%1B%28B\"

  .. tab:: Python
  
      .. code-block::
      
          >>> with encoding('UTF-8'):
          ...     print(url_encode({'iroha': 'いろは'}))
          ...
          iroha=%E3%81%84%E3%82%8D%E3%81%AF
          >>> with encoding('ISO-2022-JP'):
          ...     print(url_encode({'iroha': 'いろは'}))
          ...
          iroha=%1B%24B%24%24%24m%24O%1B%28B
          
  "
  (try
    (yield (setv local-data.encoding enc))
  (finally
    (setv local-data.encoding None))))


(defn str-of-url [split-result]
  "Make URL from ``url.parse.SplitResult`` object."
  (if (or split-result.netloc
          (is None split-result.path)
          (not (.startswith split-result.path "/")))
    (.geturl split-result)
    (as-> (getattr local-data "base_url" "") it
          (.removesuffix it "/")
          (+ it split-result.path)
          (._replace split-result :path it)
          (.geturl it))))


(defn url-encode [obj]
  "Quote `obj` for URL encoding.
  
  * If `obj` is a dict, use ``url.parse.urlencode``.
  * Else use ``url.parse.quote_plus``.
  "
  (if (isinstance obj dict)
    (urlencode obj :encoding (getattr local-data "encoding" None))
    (quote-plus obj)))


(defn to-uri [obj]
  "Convert an object to a ``url.parse.SplitResult``."
  (cond
    (isinstance obj str) (urlsplit obj)
    (isinstance obj SplitResult) obj
    True (urlsplit (str obj))))


;; Iterable utils

(defn empty? [coll]
  (= (len coll) 0))


(defclass multimethod [multimethod.multimethod]
  (defn [property] docstring [self]
    (for [func (.values self)]
      (when func.__doc__
        (return func.__doc__)))
    ""))
