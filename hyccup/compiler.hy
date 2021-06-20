(require [hy.contrib.walk [let]])

(defn compile-element [tag attrs children]
  f"<{(. tag name)}{(format-attrs attrs)}>{children}</{(. tag name)}>")

(defn compile-list [element-list]
  (setv element-len (len element-list))
  (cond
    [(= element-len 1) (compile-element #* element-list {} "")]
    [(= element-len 2) (if (isinstance (nth element-list 1) dict)
                         (compile-element #* element-list "")
                         (compile-element 
                           (first element-list)
                           {}
                           (last element-list)))]
    [(= element-len 3) (compile-element #* element-list)]))


(defn format-attrs [attrs]
  (if attrs
    (let [attrs-str (.join " " (gfor (, attr value)
                                     (.items attrs)
                                     f"{(. attr name)}=\"{value}\""))]
      f" {attrs-str}")
    ""))

