(import [fractions [Fraction]]
        [urllib.parse [ParseResult]] 
        [hy.models [Keyword Symbol]])

(defn to-str [obj]
  (cond
    [(instance? Fraction obj) (-> obj (float) (str))]
    [(instance? ParseResult obj) (.geturl obj)]
    [(instance? Symbol obj) (str obj)]
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
        [(none? obj) (RawStr "")]
        [(coll? obj) (RawStr (+ #* (map (. RawStr from-obj-or-iterable) obj)))]
        [True (RawStr obj)]))))
