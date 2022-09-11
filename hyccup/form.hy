"Functions for generating HTML forms and input fields."

(require hyccup.definition [defelem])

(import contextlib [contextmanager]
        hyrule [coll? rest]
        threading
        toolz [first]
        hyccup.core [raw]
        hyccup.util :as util)


(setv local-data (.local threading)
      local-data.group [])


(defn [contextmanager] group [group-name]
  "Group together a set of related form fields."
  (try
    (yield
      (do 
        (when (not (hasattr local-data "group"))
          (setv local-data.group []))
        (local-data.group.append group-name)))
  (finally
    (local-data.group.pop))))


(defn make-name [name]
  "Create a field name from the supplied argument the current field group."
  (let [groups-and-name (+ (getattr local-data "group" []) [name])
        remaining (gfor part (rest groups-and-name) f"[{part}]")]
    (.join "" [(first groups-and-name) #* remaining])))


(defn make-id [name]
  "Create a field id from the supplied argument and current field group."
  (let [groups-and-name (+ (getattr local-data "group" []) [name])
        remaining (gfor part (rest groups-and-name) f"-{part}")]
    (.join "" [(first groups-and-name) #* remaining])))


(defn input-field [type name value]
  "Create a new <input> element."
  ["input" {"type" type
            "name" (make-name name)
            "id" (make-id name)
            "value" value}])


(defelem hidden-field [name [value None]]
  "Create a hidden input field.
  
  :param attrs-map: Optional dict of attributes as first positional parameter
  :param name: The name of the field
  :param value: Its value (default: None)
  "
  (input-field "hidden" name value))


(defelem text-field [name [value None]]
  "Create a new text input field.
  
  :param attrs-map: Optional dict of attributes as first positional parameter
  :param name: The name of the field
  :param value: Its value (default: None)
  "
  (input-field "text" name value))


(defelem password-field [name [value None]]
  "Create a new password field.
  
  :param attrs-map: Optional dict of attributes as first positional parameter
  :param name: The name of the field
  :param value: Its value (default: None)
  "
  (input-field "password" name value))


(defelem email-field [name [value None]]
  "Create a new email input field.
  
  :param attrs-map: Optional dict of attributes as first positional parameter
  :param name: The name of the field
  :param value: Its value (default: None)
  "
  (input-field "email" name value))


(defelem check-box [name [checked? None] [value "true"]]
  "Create a check box.
  
  :param attrs-map: Optional dict of attributes as first positional parameter
  :param name: The name of the checkbox
  :param checked?: Boolean attribute \"checked\" (default: None)
  :param value: Its value (default: \"true\")
  "
  ["input" {"type" "checkbox"
            "name" (make-name name)
            "id" (make-id name)
            "value" value
            "checked" checked?}])


(defelem radio-button [group [checked? None] [value "true"]]
  "Create a radio button.
  
  :param attrs-map: Optional dict of attributes as first positional parameter
  :param group: The group of the radio button
  :param checked?: Boolean attribute \"checked\" (default: None)
  :param value: Its value (default: \"true\")
  "
  ["input" {"type" "radio"
            "name" (make-name group)
            "id" (make-id f"{(util.as-str group)}-{(util.as-str value)}")
            "value" value
            "checked" checked?}])


(defelem select-options [coll [selected None]]
  "Create a seq of option tags from a collection.
  
  :param attrs-map: Optional dict of attributes as first positional parameter
  :param coll: Collection of options. Items should be (text, val)
  :param selected: Selected item (an available value) (default: None)
  "
  (gfor x coll
    (if (coll? x)
      (let [[text val] x]
        (if (coll? val)
          ["optgroup" {"label" text} (select-options val selected)]
          ["option" {"value" val "selected" (= val selected)} text]))
      ["option" {"selected" (= x selected)} x])))


(defelem drop-down [name options [selected None]]
  "Create a drop-down box using the `<select>` tag.
  
  :param attrs-map: Optional dict of attributes as first positional parameter
  :param options: A collection of options (passed to :hy:func:`select-options`)
  :param selected: Selected option (passed to :hy:func:`select-options`)
  "
  ["select" {"name" (make-name name) "id" (make-id name)}
    (select-options options selected)])


(defelem text-area [name [value None]]
  "Create a text area element.
  
  :param attrs-map: Optional dict of attributes as first positional parameter
  :param name: The name of the text area
  :param value: Its value (default: None)
  "
  ["textarea" {"name" (make-name name) "id" (make-id name)} value])


(defelem file-upload [name]
  "Create a file upload input.
  
  :param attrs-map: Optional dict of attributes as first positional parameter
  :param name: The name of the field
  "
  (input-field "file" name None))


(defelem label [name text]
  "Create a label for an input field with the supplied name.
  
  :param attrs-map: Optional dict of attributes as first positional parameter
  :param name: The name of the field
  :param text: Its text
  "
  ["label" {"for" (make-id name)} text])


(defelem submit-button [text]
  "Create a submit button.
  
  :param attrs-map: Optional dict of attributes as first positional parameter
  :param name: The text of the button
  "
  ["input" {"type" "submit" "value" text}])


(defelem reset-button [text]
  "Create a form reset button.
  
  :param attrs-map: Optional dict of attributes as first positional parameter
  :param name: The text of the button
  "
  ["input" {"type" "reset" "value" text}])


(defelem form-to [method-and-action #* body]
  "Create a form that points to a particular method and route.
  
  :param attrs-map: Optional dict of attributes as first positional parameter
  :param method-and-action: collection containing method and action (e.g. ``[\"post\" \"/foo\"]``)
  :param \\*body: The body of the form
  "
  (setv [method action] method-and-action
        method-str (.upper method)
        action-uri (util.to-uri action))
  (+ (if (in (str method) #{"get" "post"})
        ["form" {"method" method-str "action" action-uri}]
        ["form" {"method" "POST" "action" action-uri}
          (hidden-field "_method" method-str)])
      [(iter body)]))
