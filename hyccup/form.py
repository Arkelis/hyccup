"""Functions for generating HTML forms and input fields."""
from contextlib import contextmanager
from hyrule import is_coll
import threading
from toolz import first
from hyccup import raw
from hyccup.definition import defelem
import hyccup.util as util


class FieldGroup:
    def __init__(self, *group_names):
        self.group_names = group_names

    @contextmanager
    def group(self, group_name):
        yield self.__class__(*self.group_names, group_name)

    def make_name(self, name):
        """Create a field name from the supplied argument the current field group."""
        first, *rest = *self.group_names, name
        remaining = (f"[{part}]" for part in rest)
        return "".join([first, *remaining])

    def make_id(self, name):
        """Create a field id from the supplied argument and current field group."""
        first, *rest = *self.group_names, name
        remaining = (f"-{part}" for part in rest)
        return "".join([first, *remaining])

    def input_field(self, type, name, value):
        """Create a new <input> element."""
        return [
            "input",
            {
                "type": type,
                "name": self.make_name(name),
                "id": self.make_id(name),
                "value": value,
            },
        ]

    @defelem.method
    def hidden_field(self, name, value=None):
        """Create a hidden input field.

        :param attrs-map: Optional dict of attributes as first positional parameter
        :param name: The name of the field
        :param value: Its value (default: None)
        """
        return self.input_field("hidden", name, value)

    @defelem.method
    def text_field(self, name, value=None):
        """Create a new text input field.

        :param attrs-map: Optional dict of attributes as first positional parameter
        :param name: The name of the field
        :param value: Its value (default: None)
        """
        return self.input_field("text", name, value)

    @defelem.method
    def password_field(self, name, value=None):
        """Create a new password field.

        :param attrs-map: Optional dict of attributes as first positional parameter
        :param name: The name of the field
        :param value: Its value (default: None)
        """
        return self.input_field("password", name, value)

    @defelem.method
    def email_field(self, name, value=None):
        """Create a new email input field.

        :param attrs-map: Optional dict of attributes as first positional parameter
        :param name: The name of the field
        :param value: Its value (default: None)
        """
        return self.input_field("email", name, value)

    @defelem.method
    def check_box(self, name, is_checked=None, value="true"):
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
                "name": self.make_name(name),
                "id": self.make_id(name),
                "value": value,
                "checked": is_checked,
            },
        ]

    @defelem.method
    def radio_button(self, group, is_checked=None, value="true"):
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
                "name": self.make_name(group),
                "id": self.make_id(f"{util.as_str(group)}-{util.as_str(value)}"),
                "value": value,
                "checked": is_checked,
            },
        ]

    def select_options(self, coll, selected=None):
        """Create a seq of option tags from a collection.

        :param attrs-map: Optional dict of attributes as first positional parameter
        :param coll: Collection of options. Items should be (text, val)
        :param selected: Selected item (an available value) (default: None)
        """

        def option_child(opt):
            match opt:
                case [label, [*sub_opts]]:
                    return [
                        "optgroup",
                        {"label": label},
                        self.select_options(sub_opts, selected),
                    ]
                case [label, value]:
                    return [
                        "option",
                        {"value": value, "selected": value == selected},
                        label,
                    ]
                case label:
                    return ["option", {"selected": label == selected}, label]

        return (option_child(opt) for opt in coll)

    @defelem.method
    def drop_down(self, name, options, selected=None):
        """Create a drop-down box using the `<select>` tag.

        :param attrs-map: Optional dict of attributes as first positional parameter
        :param options: A collection of options (passed to :hy:func:`select-options`)
        :param selected: Selected option (passed to :hy:func:`select-options`)
        """
        return [
            "select",
            {"name": self.make_name(name), "id": self.make_id(name)},
            self.select_options(options, selected),
        ]

    @defelem.method
    def text_area(self, name, value=None):
        """Create a text area element.

        :param attrs-map: Optional dict of attributes as first positional parameter
        :param name: The name of the text area
        :param value: Its value (default: None)
        """
        return [
            "textarea",
            {"name": self.make_name(name), "id": self.make_id(name)},
            value,
        ]

    @defelem.method
    def file_upload(self, name):
        """Create a file upload input.

        :param attrs-map: Optional dict of attributes as first positional parameter
        :param name: The name of the field
        """
        return self.input_field("file", name, None)

    @defelem.method
    def label(self, name, text):
        """Create a label for an input field with the supplied name.

        :param attrs-map: Optional dict of attributes as first positional parameter
        :param name: The name of the field
        :param text: Its text
        """
        return ["label", {"for": self.make_id(name)}, text]


@contextmanager
def group(group_name):
    """Group together a set of related form fields."""
    yield FieldGroup(group_name)

_top_group = FieldGroup()


@defelem
def hidden_field(name, value=None):
    """Create a hidden input field.

    :param attrs-map: Optional dict of attributes as first positional parameter
    :param name: The name of the field
    :param value: Its value (default: None)
    """
    return _top_group.hidden_field(name, value)


@defelem
def text_field(name, value=None):
    """Create a new text input field.

    :param attrs-map: Optional dict of attributes as first positional parameter
    :param name: The name of the field
    :param value: Its value (default: None)
    """
    return _top_group.text_field(name, value)


@defelem
def password_field(name, value=None):
    """Create a new password field.

    :param attrs-map: Optional dict of attributes as first positional parameter
    :param name: The name of the field
    :param value: Its value (default: None)
    """
    return _top_group.password_field(name, value)


@defelem
def email_field(name, value=None):
    """Create a new email input field.

    :param attrs-map: Optional dict of attributes as first positional parameter
    :param name: The name of the field
    :param value: Its value (default: None)
    """
    return _top_group.email_field(name, value)


@defelem
def check_box(name, is_checked=None, value="true"):
    """Create a check box.

    :param attrs-map: Optional dict of attributes as first positional parameter
    :param name: The name of the checkbox
    :param checked?: Boolean attribute "checked" (default: None)
    :param value: Its value (default: "true")
    """
    return _top_group.check_box(name, is_checked, value)


@defelem
def radio_button(group, is_checked=None, value="true"):
    """Create a radio button.

    :param attrs-map: Optional dict of attributes as first positional parameter
    :param group: The group of the radio button
    :param checked?: Boolean attribute "checked" (default: None)
    :param value: Its value (default: "true")
    """
    return _top_group.radio_button(group, is_checked, value)


def select_options(coll, selected=None):
    """Create a seq of option tags from a collection.

    :param attrs-map: Optional dict of attributes as first positional parameter
    :param coll: Collection of options. Items should be (text, val)
    :param selected: Selected item (an available value) (default: None)
    """
    return _top_group.select_options(coll, selected)


@defelem
def drop_down(name, options, selected=None):
    """Create a drop-down box using the `<select>` tag.

    :param attrs-map: Optional dict of attributes as first positional parameter
    :param options: A collection of options (passed to :hy:func:`select-options`)
    :param selected: Selected option (passed to :hy:func:`select-options`)
    """
    return _top_group.drop_down(name, options, selected)


@defelem
def text_area(name, value=None):
    """Create a text area element.

    :param attrs-map: Optional dict of attributes as first positional parameter
    :param name: The name of the text area
    :param value: Its value (default: None)
    """
    return _top_group.text_area(name, value)


@defelem
def file_upload(name):
    """Create a file upload input.

    :param attrs-map: Optional dict of attributes as first positional parameter
    :param name: The name of the field
    """
    return _top_group.file_upload(name)


@defelem
def label(name, text):
    """Create a label for an input field with the supplied name.

    :param attrs-map: Optional dict of attributes as first positional parameter
    :param name: The name of the field
    :param text: Its text
    """
    return _top_group.label(name, text)


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
