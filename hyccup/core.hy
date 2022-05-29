(require hyrule [->])

(import hyccup.compiler [Compiler RawStr]) 


(defn html [#* content [mode "xhtml"] [escape-strings True]]
  "Compile data structure into an HTML raw string.

  RawStr is a subclass of str, so it can be manipulated just like a string.

  :param \\*content: One or more lists representing HTML to render.
  :param mode: The HTML mode: ``\"html\"`` / ``\"xml\"`` / ``\"xhtml\"`` (default).
  :param escape-strings: Boolean indicating if strings must be escaped
                         (default: ``True``).
  :rtype: :class:`hyccup.util.RawStr`
  "
  (-> (Compiler mode escape-strings)
      (.compile-html #* content)
      (raw)))


(defn raw [obj]
  "Produce a raw string from obj.
  
  Raw strings are not escaped.
  If `obj` is a collection, concatenate the string representation of the 
  contained elements.

  :rtype: :class:`hyccup.util.RawStr`
  "
  (.from-obj-or-iterable RawStr obj))
