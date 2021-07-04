(require [hy.contrib.walk [let]])
(import [hyccup.util [escape-html RawStr]]
        re)


;; HTML mode handling

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


;; Tag abbreviation

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


;; Attributes sorting

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


;; Compilation

(defclass Compiler []
  (defn __init__ [self mode escape-strings]
    (setv self.mode mode
          self.escape-strings escape-strings))
  
  (defn compile-html [self #* content]
    "Compile HTML content to string."
    (if (coll? (first content))
      (.join "" (map self.compile-element-exp content))
      (self.compile-element-exp content)))

  (defn compile-element-exp [self exp]
    "Compile any expression representing an element to a HTML string.
    
    Called by self.compile-html.
    "
    (cond
      [(coll? exp) (self.compile-list exp)]
      [(instance? RawStr exp) exp]
      [True (escape-html (str exp) self.mode self.escape-strings)]))

  (defn compile-list [self element-list]
    "Take an element list and call render-element to render it.
    
    Called by self.compile-element-exp.
    "
    (unless (instance? str (first element-list))
      (raise (TypeError f"{(first element-list)} must be a string or symbol.")))
    (if (= (len element-list) 1) 
      (self.render-element #* element-list {})
      (if (instance? dict (second element-list))
        (self.render-element #* element-list)
        (self.render-element (first element-list) {} #* (cut element-list 1)))))

  (defn render-element [self tag attrs #* children]
    "Render an element list to HTML string recursively.
    
    Take a tag, an attributes dictionary and children as positional arguments
    Take the HTML mode as keyword argument
    
    Return a string of the HTML representation of the element.
    Call compile-element-exp for rendering its children.
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
      (+ f"<{tag-name}{(self.format-attrs-dict attrs)}"
         (if (container-tag? tag-name self.mode)
           f"></{tag-name}>"
           (if (xml-mode? self.mode) " />" ">" )))
      (if (void-tag? tag-name)
        (raise (ValueError f"'{tag-name}' cannot have children"))
        (do 
          (setv compiled-children 
            (.join "" (map (fn [el] (self.compile-element-exp el)) children)))
          (+ f"<{tag-name}{(self.format-attrs-dict attrs)}>"
            f"{compiled-children}"
            f"</{tag-name}>")))))

  (defn format-attr [self attr value]
    (cond
      [(is value True) 
        (if (xml-mode? self.mode)
          f"{(str attr)}=\"{(str attr)}\""
          f"{(str attr)}")]
      [(not value) ""]
      [True
        (do
          (setv attr-value-str 
            (escape-html (str value) self.mode self.escape-strings))
          f"{(str attr)}=\"{attr-value-str}\"")]))


  (defn format-attrs-dict [self attrs-dict]
    "Convert attributes dictionary to string."
    (if attrs-dict
      (let [attrs-str (->>
                        (gfor (, attr value)
                              (sorted (.items attrs-dict) :key attr-key)
                              (self.format-attr attr value))
                        (remove empty?)
                        (.join " "))]
        (if (empty? attrs-str) "" f" {attrs-str}"))
      "")))
