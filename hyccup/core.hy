(import [hyccup.compiler [Compiler RawStr]])


(defn raw [obj]
  "Produce a raw string from obj.
  
  Raw strings are not escaped.
  If obj is a collection, concatenate the string representation of the 
  contained elements.
  "
  (.from-obj-or-iterable RawStr obj))


(defn html [#* content [mode "xhtml"] [escape-strings True]]
  "Compile data structure into an HTML raw string.

  RawStr is a subclass of str, so it can be manipulated just like a string.
  "
  (-> (Compiler mode escape-strings)
      (.compile-html #* content)
      (raw)))
