"""Functions for generating HTML forms and input fields."""
from contextlib import contextmanager
from hyrule import is_coll
import threading
from toolz import first
from hyccup import raw
from hyccup.definition import defelem
import hyccup.util as util

local_data = threading.local()
local_data.group = []


@contextmanager
def group(group_name):
    """Group together a set of related form fields."""
    try:
        if not hasattr(local_data, "group"):
            local_data.group = []
        local_data.group.append(group_name)
        yield 
    finally:
        local_data.group.pop()


def make_name(name):
    """Create a field name from the supplied argument the current field group."""
    groups_and_name = getattr(local_data, "group", []) + [name]
    first, *rest = groups_and_name
    remaining = (f"[{part}]" for part in rest)
    return "".join([first, *remaining])


def make_id(name):
    """Create a field id from the supplied argument and current field group."""
    groups_and_name = getattr(local_data, "group", []) + [name]
    first, *rest = groups_and_name
    remaining = (f"-{part}" for part in rest)
    return "".join([first, *remaining])


def input_field(type, name, value):
    """Create a new <input> element."""
    return [
        "input",
        {"type": type, "name": make_name(name), "id": make_id(name), "value": value},
    ]


@defelem
def hidden_field(name, value=None):
    """Create a hidden input field.

    :param attrs-map: Optional dict of attributes as first positional parameter
    :param name: The name of the field
    :param value: Its value (default: None)
    """
    return input_field("hidden", name, value)


@defelem
def text_field(name, value=None):
    """Create a new text input field.

    :param attrs-map: Optional dict of attributes as first positional parameter
    :param name: The name of the field
    :param value: Its value (default: None)
    """
    return input_field("text", name, value)


@defelem
def password_field(name, value=None):
    """Create a new password field.

    :param attrs-map: Optional dict of attributes as first positional parameter
    :param name: The name of the field
    :param value: Its value (default: None)
    """
    return input_field("password", name, value)


@defelem
def email_field(name, value=None):
    """Create a new email input field.

    :param attrs-map: Optional dict of attributes as first positional parameter
    :param name: The name of the field
    :param value: Its value (default: None)
    """
    return input_field("email", name, value)


@defelem
def check_box(name, is_checked=None, value="true"):
    """Create a check box.

    :param attrs-map: Optional dict of attributes as first positional parameter
    :param name: The name of the checkbox
    :param checked?: Boolean attribute "checked" (default: None)
    :param value: Its value (default: "true")
    """
    return [
        "input",
        {
            "type": "checkbox",
            "name": make_name(name),
            "id": make_id(name),
            "value": value,
            "checked": is_checked,
        },
    ]


@defelem
def radio_button(group, is_checked=None, value="true"):
    """Create a radio button.

    :param attrs-map: Optional dict of attributes as first positional parameter
    :param group: The group of the radio button
    :param checked?: Boolean attribute "checked" (default: None)
    :param value: Its value (default: "true")
    """
    return [
        "input",
        {
            "type": "radio",
            "name": make_name(group),
            "id": make_id(f"{util.as_str(group)}-{util.as_str(value)}"),
            "value": value,
            "checked": is_checked,
        },
    ]


@defelem
def select_options(coll, selected=None):
    """Create a seq of option tags from a collection.

    :param attrs-map: Optional dict of attributes as first positional parameter
    :param coll: Collection of options. Items should be (text, val)
    :param selected: Selected item (an available value) (default: None)
    """
    def option_child(opt):
        match opt:
            case [label, [*sub_opts]]:
              return ["optgroup", {"label": label}, select_options(sub_opts, selected)]
            case [label, value]:
              return ["option", {"value": value, "selected": value == selected}, label]
            case label:
              return ["option", {"selected": label == selected}, label]
    
    return (option_child(opt) for opt in coll)


@defelem
def drop_down(name, options, selected=None):
    """Create a drop-down box using the `<select>` tag.

    :param attrs-map: Optional dict of attributes as first positional parameter
    :param options: A collection of options (passed to :hy:func:`select-options`)
    :param selected: Selected option (passed to :hy:func:`select-options`)
    """
    return [
        "select",
        {"name": make_name(name), "id": make_id(name)},
        select_options(options, selected),
    ]


@defelem
def text_area(name, value=None):
    """Create a text area element.

    :param attrs-map: Optional dict of attributes as first positional parameter
    :param name: The name of the text area
    :param value: Its value (default: None)
    """
    return ["textarea", {"name": make_name(name), "id": make_id(name)}, value]


@defelem
def file_upload(name):
    """Create a file upload input.

    :param attrs-map: Optional dict of attributes as first positional parameter
    :param name: The name of the field
    """
    return input_field("file", name, None)


@defelem
def label(name, text):
    """Create a label for an input field with the supplied name.

    :param attrs-map: Optional dict of attributes as first positional parameter
    :param name: The name of the field
    :param text: Its text
    """
    return ["label", {"for": make_id(name)}, text]


@defelem
def submit_button(text):
    """Create a submit button.

    :param attrs-map: Optional dict of attributes as first positional parameter
    :param name: The text of the button
    """
    return ["input", {"type": "submit", "value": text}]


@defelem
def reset_button(text):
    """Create a form reset button.

    :param attrs-map: Optional dict of attributes as first positional parameter
    :param name: The text of the button
    """
    return ["input", {"type": "reset", "value": text}]


@defelem
def form_to(method_and_action, *body):
    """Create a form that points to a particular method and route.

    :param attrs-map: Optional dict of attributes as first positional parameter
    :param method-and-action: collection containing method and action (e.g. ``["post" "/foo"]``)
    :param \\*body: The body of the form
    """
    method, action = method_and_action
    method_str = method.upper()
    action_uri = util.to_uri(action)

    if method in {"get", "post"}:
      form_elem = ["form", {"method": method_str, "action": action_uri}]
    else:
      form_elem = [
            "form",
            {"method": "POST", "action": action_uri},
            hidden_field("_method", method_str),
        ]
    return form_elem + [iter(body)]
