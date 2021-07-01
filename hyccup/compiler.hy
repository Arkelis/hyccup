(require [hy.contrib.walk [let]])
(import [hyccup.util [to-str]])


(setv void-tags 
  #{"area" "base" "br" "col" "command" "embed" "hr" "img" "input" "keygen"
    "link" "meta" "param" "source" "track" "wbr"})

(defn void-tag? [tag-name]
  (in tag-name void-tags))

(defn compile-exp [exp]
  (cond
    [(instance? list exp) (compile-list exp)]
    [(instance? str exp) exp]))


(defn render-element [tag attrs children]
  (setv tag-name (to-str tag))
  (if (void-tag? tag-name)
    (if (not (empty? children))
      (raise (ValueError f"'{tag-name}' cannot have children"))
      f"<{tag-name}{(format-attrs attrs)}>")
    f"<{tag-name}{(format-attrs attrs)}>{(compile-exp children)}</{tag-name}>"))


(defn compile-list [element-list]
  (setv element-len (len element-list))
  (cond
    [(= element-len 1) (render-element #* element-list {} "")]
    [(= element-len 2) (if (instance? dict (last element-list))
                         (render-element #* element-list "")
                         (render-element 
                           (first element-list)
                           {}
                           (last element-list)))]
    [(= element-len 3) (render-element #* element-list)]))


(defn format-attrs [attrs]
  (if attrs
    (let [attrs-str (.join " " (gfor (, attr value)
                                     (.items attrs)
                                     f"{(. attr name)}=\"{value}\""))]
      f" {attrs-str}")
    ""))

