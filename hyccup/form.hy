"""Functions for generating HTML forms and input fields."""

(import [contextlib [contextmanager]]
        threading
        [toolz [first]]
        [hyccup.core [raw]]
        [hyccup.util :as util])

(require [hyccup.defmacros [defelem]]
         [hy.contrib.walk [let]])


(setv local-data (.local threading)
      local-data.group [])


(with-decorator contextmanager
  (defn group [group-name]
    "Group together a set of related form fields for use with the Ring
    nested-params middleware."
    (try
      (yield (.append local-data.group group-name))
    (finally
      (.pop local-data.group)))))


(defn make-name [name]
  "Create a field name from the supplied argument the current field group."
  (setv groups-and-name (+ local-data.group [name])
        remaining (gfor part (rest groups-and-name) f"[{part}]"))
  (.join "" [(first groups-and-name) #* remaining]))


(defn make-id [name]
  "Create a field id from the supplied argument and current field group."
  (setv groups-and-name (+ local-data.group [name])
        remaining (gfor part (rest groups-and-name) f"-{part}"))
  (.join "" [(first groups-and-name) #* remaining]))


(defn input-field [type name value]
  "Create a new <input> element."
  ['input {'type type
           'name (make-name name)
           'id (make-id name)
           'value value}])


(defelem hidden-field [name [value None]]
  "Create a hidden input field."
  (input-field "hidden" name value))


(defelem text-field [name [value None]]
  "Create a new text input field."
  (input-field "text" name value))


(defelem password-field [name [value None]]
  "Create a new password field."
  (input-field "password" name value))


(defelem email-field [name [value None]]
  "Create a new email input field."
  (input-field "email" name value))


(defelem check-box [name [checked? None] [value "true"]]
  "Create a check box."
  ['input {'type "checkbox"
           'name (make-name name)
           'id (make-id name)
           'value value
           'checked checked?}])


(defelem radio-button [group [checked? None] [value "true"]]
  "Create a radio button."
  ['input {'type "radio"
           'name (make-name group)
           'id (make-id f"{(util.as-str group)}-{(util.as-str value)}")
           'value value
           'checked checked?}])


(defelem select-options [coll [selected None]]
  "Create a seq of option tags from a collection."
  (gfor x coll
    (if (coll? x)
      (let [[text val] x]
        (if (coll? val)
          ['optgroup {'label text} (select-options val selected)]
          ['option {'value val 'selected (= val selected)} text]))
      ['option {'selected (= x selected)} x])))


(defelem drop-down [name options [selected None]]
  "Create a drop-down box using the `<select>` tag."
  ['select {'name (make-name name) 'id (make-id name)}
    (select-options options selected)])


(defelem text-area [name [value None]]
  "Create a text area element."
  ['textarea {'name (make-name name) 'id (make-id name)} value])


(defelem file-upload [name]
  "Create a file upload input."
  (input-field "file" name None))


(defelem label [name text]
  "Create a label for an input field with the supplied name."
  ['label {"for" (make-id name)} text])


(defelem submit-button [text]
  "Create a submit button."
  ['input {'type "submit" 'value text}])


(defelem reset-button [text]
  "Create a form reset button."
  ['input {'type "reset" 'value text}])


(defelem form-to [method-and-action #* body]
  "Create a form that points to a particular method and route.
  For example:
      (form-to [:put \"/post\"]
        ...)"
  (setv [method action] method-and-action
        method-str (.upper method)
        action-uri (util.to-uri action))
  (+ (if (in (str method) #{"get" "post"})
        ['form {'method method-str 'action action-uri}]
        ['form {'method "POST" 'action action-uri}
          (hidden-field "_method" method-str)])
      [(iter body)]))
