(require [hy.contrib.walk [let]])
(import [hyccup.util [to-str]]
        re)


(setv tag-re (re.compile r"([^\s\.#]+)(?:#([^\s\.#]+))?(?:\.([^\s#]+))?"))

(setv void-tags 
  #{"area" "base" "br" "col" "command" "embed" "hr" "img" "input" "keygen"
    "link" "meta" "param" "source" "track" "wbr"})

(defn void-tag? [tag-name]
  (in tag-name void-tags))

(defn compile-exp [exp]
  (cond
    [(instance? list exp) (compile-list exp)]
    [(instance? str exp) exp]))

(defn expand-tag-keyword [tag]
  (setv tag-str (to-str tag)
        [tag-name id attrs] (-> (.match tag-re tag-str)
                                (.group 1 2 3)))
  [tag-name id (.replace (or attrs "") "." " ")])


(defn render-element [tag attrs children]
  (setv [tag-name id classes] (expand-tag-keyword tag))
  (if id
    (unless (in :id attrs) (assoc attrs :id id)))
  (if classes
    (assoc attrs :class (+ (.get attrs :class "") f" {classes}")))
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

