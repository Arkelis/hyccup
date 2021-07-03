(import [hy.models [Keyword Symbol]])

;; (defn to-str [obj]
;;   (cond
;;     [(instance? Symbol obj) (str obj)]
;;     [(instance? str obj) obj]
;;     [True (raise (ValueError f"{obj} is not a valid element name."))]))

(defn escape-html [string mode]
  "Change special characters into HTML character entities."
  (-> string
      (.replace "&"  "&amp;")
      (.replace "<"  "&lt;")
      (.replace ">"  "&gt;")
      (.replace "\"" "&quot;")
      (.replace "'" (if (= (str mode) "sgml") "&#39;" "&apos;"))))
