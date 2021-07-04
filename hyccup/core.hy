(import [hyccup.compiler [Compiler RawStr]])


(defn html [#* content [mode "xhtml"] [escape-strings True]]
  (-> (Compiler mode escape-strings)
      (.compile-html #* content)))


(defn raw [obj]
  "Produce a raw string from obj.
  
  Raw strings are not escaped.
  If obj is a collection, concatenate the string representation of the 
  contained elements.
  "
  (.from-obj-or-iterable RawStr obj))
