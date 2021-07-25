"Functions for creating generic HTML elements."

(import [hyccup.util :as util])

(require [hyccup.defmacros [defelem]])


(defn javascript-tag [script]
  "Wrap the supplied javascript up in script tags and a CDATA section."
  ['script {'type "text/javascript"} f"//<![CDATA[\n{script}\n//]]>"])


(defelem link-to [url #* content]
  "Wrap some content in a HTML hyperlink with the supplied URL."
  ['a {'href (util.to-uri url)} #* content])


(defelem mail-to [email #* content]
  "Wrap some content in a HTML hyperlink with the supplied e-mail
  address. If no content provided use the e-mail address as content."
  (setv el ['a {'href f"mailto:{email}"}
             #* content])
  (unless content (.append el email))
  el)


(defelem unordered-list [coll]
  "Wrap a collection in an unordered list."
  ['ul (gfor x coll ['li x])])


(defelem ordered-list [coll]
  "Wrap a collection in an ordered list."
  ['ol (gfor x coll ['li x])])


(defelem image [src [alt None]]
  "Create an image element."
  ['img {'src (util.to-uri src) 'alt alt}])
