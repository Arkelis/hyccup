(require [hy.contrib.walk [let]])
(import [hyccup.util [escape-html]]
        re)


;; Tag name and abbreviation

(defn xml-mode? [mode]
  (in (str mode) #{"xml" "xhtml"}))

(defn html-mode? [mode]
  (in (str mode) #{"html" "xhtml"}))

(defn void-tag? [tag-name]
  (in tag-name
    #{"area" "base" "br" "col" "command" "embed" "hr" "img" "input" "keygen"
    "link" "meta" "param" "source" "track" "wbr"}))

(defn container-tag? [tag-name mode]
  (and (html-mode? mode) (not (void-tag? tag-name))))

(defn expand-tag-abb [tag]
  "Expand a tag abbreviation
  
  Take a str or symbol and return a list containing:
  - the name of the element
  - its id
  - its classes
  "
  (setv tag-abb-str (str tag)
        tag-abb-re r"([^\s\.#]+)(?:#([^\s\.#]+))?(?:\.([^\s#]+))?"
        compiled-re (re.compile tag-abb-re)
        [tag-name id attrs] (-> (.match compiled-re tag-abb-str)
                                (.group 1 2 3)))
  [tag-name id (.replace (or attrs "") "." " ")])


;; Attributes

(defn attr-key [t]
  "Sorting key function.
  
  'class' attribute is always first.
  'id' attribute follows 'class'.
  'data-*' attributes follow 'id'.
  "
  (setv attr-name 
    (-> (get t 0)
        (str)))
  (cond [(= attr-name "class") "0"]
        [(= attr-name "id") "1"]
        [(.startswith attr-name "data") f"2{attr-name}"]
        [True f"3{attr-name}"]))


(defn format-attr [attr value mode]
  (cond
    [(is value True) 
       (if (xml-mode? mode)
         f"{(str attr)}=\"{(str attr)}\""
         f"{(str attr)}")]
    [(not value) ""]
    [True
      f"{(str attr)}=\"{(escape-html (str value) mode)}\""]))


(defn format-attrs-dict [attrs mode]
  "Convert attributes dictionary to string."
  (if attrs
    (let [attrs-str (->>
                      (gfor (, attr value)
                            (sorted (.items attrs) :key attr-key)
                            (format-attr attr value mode))
                      (remove empty?)
                      (.join " "))]
      (if (empty? attrs-str) "" f" {attrs-str}"))
    ""))


;; Elements compilation

(defn render-element [tag attrs #* children mode]
  "Render an element list to HTML string recursively.
  
  Take a tag, an attributes dictionary and children as positional arguments
  Take the HTML mode as keyword argument
  
  Return a string of the HTML representation of the element.
  Call compile-exp for rendering its children.
  Called by compile-list.
  "
  (setv [tag-name id classes] (expand-tag-abb tag))
  (if id
    (unless (in "id" attrs) (assoc attrs "id" id)))
  (if classes
    (assoc attrs "class"
      (.join " " (remove empty? [f"{classes}" 
                                 (let [dict-classes (.get attrs "class" "")]
                                   (if (coll? dict-classes)
                                     (.join " " dict-classes)
                                     dict-classes))]))))
  (if (empty? children)
    (+ f"<{tag-name}{(format-attrs-dict attrs mode)}"
       (if (container-tag? tag-name mode)
         f"></{tag-name}>"
         (if (xml-mode? mode) " />" ">" )))
    (if (void-tag? tag-name)
      (raise (ValueError f"'{tag-name}' cannot have children"))
      (do 
        (setv compiled-children (.join "" (map (fn [el] (compile-exp el mode)) children)))
        f"<{tag-name}{(format-attrs-dict attrs mode)}>{compiled-children}</{tag-name}>"))))


(defn compile-list [element-list mode]
  "Take an element list and call render-element to render it.
  
  Called by compile-exp.
  "
  (unless (instance? str (first element-list))
    (raise (TypeError f"{(first element-list)} must be a string or symbol.")))
  (if (= (len element-list) 1) 
    (render-element #* element-list {} :mode mode)
    (if (instance? dict (second element-list))
      (render-element #* element-list :mode mode)
      (render-element 
        (first element-list) {} #* (cut element-list 1)
        :mode mode))))


(defn compile-exp [exp mode]
  "Compile any expression to a HTML string.
  
  Called by core.html.
  "
  (cond
    [(coll? exp) (compile-list exp mode)]
    [True (escape-html (str exp) mode)]))
