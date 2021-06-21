(require [hy.contrib.walk [let]])
(import [hyccup.util [to-str]])


(defn compile-exp [exp]
  (cond
    [(instance? list exp) (compile-list exp)]
    [(instance? str exp) exp]))


(defn compile-element [tag attrs children]
  (setv tag-name (to-str tag))
  f"<{tag-name}{(format-attrs attrs)}>{(compile-exp children)}</{tag-name}>")


(defn compile-list [element-list]
  (setv element-len (len element-list))
  (cond
    [(= element-len 1) (compile-element #* element-list {} "")]
    [(= element-len 2) (if (instance? dict (last element-list))
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

