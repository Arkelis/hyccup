(import [hyccup.core [html raw]]
        [hyccup.util :as util]
        [toolz [first merge]])

(require [hyccup.defmacros [defelem]])


(setv doctype
  {"html4"
   (raw ["<!DOCTYPE html PUBLIC \"-//W3C//DTD HTML 4.01//EN\" "
         "\"http://www.w3.org/TR/html4/strict.dtd\">\n"])
   "xhtml_strict"
   (raw ["<!DOCTYPE html PUBLIC \"-//W3C//DTD XHTML 1.0 Strict//EN\" "
         "\"http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd\">\n"])
   "xhtml_transitional"
   (raw ["<!DOCTYPE html PUBLIC \"-//W3C//DTD XHTML 1.0 Transitional//EN\" "
         "\"http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd\">\n"])
   "html5"
   (raw "<!DOCTYPE html>\n")})


(defelem xhtml-tag [lang #* contents]
  "Create an XHTML element for the specified language."
  ['html {'xmlns "http://www.w3.org/1999/xhtml"
          "xml:lang" lang
          'lang lang}
    #* contents])


(defn xml-declaration [encoding]
  "Create a standard XML declaration for the following encoding."
  (raw ["<?xml version=\"1.0\" encoding=\"" encoding "\"?>\n"]))


(defn html4 [#* contents]
  "Create a HTML 4 document with the supplied contents.
  
  The first argument may be an optional attribute map."
  (html 
    (:html4 doctype)
    ['html #* contents]
    :mode "sgml"))


(defn split-attrs-and-content [contents]
  (if (isinstance (first contents) dict)
    (, (first contents) (rest contents))
    (, {} contents)))

(defn xhtml [#* contents [lang None] [encoding "UTF-8"]]
  "Create a XHTML 1.0 strict document with the supplied contents.
  
  Keyword arguments:
  * `lang` - The language of the document
  * `encoding` - The character encoding of the document (defaults to UTF-8).
  "
  (setv [attrs contents] (split-attrs-and-content contents))
  (html
    (xml-declaration encoding)
    (:xhtml-strict doctype)
    (xhtml-tag lang attrs #* contents)
    :mode "xhtml"))

(defn html5 [#* contents [lang None] [xml False] [encoding "UTF-8"]]
  "Create a HTML5 document with the supplied contents.
  
  Keyword argument:
  - `xml` - If True, use html with xml mode.
  - `encoding` - The character encoding of the document (defaults to UTF-8).
  - `lang` - The language of the document.
  "
  (setv [attrs contents] (split-attrs-and-content contents))
  (if xml
    (html
      (xml-declaration encoding)
      (:html5 doctype)
      (xhtml-tag lang attrs #* contents)
      :mode "xml")
    (html
      (:html5 doctype)
      ['html (merge attrs {"lang" lang}) #* contents]
      :mode "html")))

(defn include-js [#* scripts]
  "Include a list of external javascript files."
  (lfor script scripts
    ['script {'type "text/javascript" 'src (util.to-uri script)}]))

(defn include-css [#* styles]
  "Include a list of external stylesheet files."
  (lfor style styles
    ['link {'type "text/css" 'href (util.to-uri style) 'rel "stylesheet"}]))
