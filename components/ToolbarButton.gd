## Emits a signal with the menu item text and item check state.
class_name ToolbarButton

signal item_pressed(item_text, is_checked)
# Bug: When multiple items between ToolbarButtons share the same text, their signals are identical.

extends MenuButton

func _ready() -> void:
	get_popup().connect("index_pressed", self, "_on_popup_index_pressed")

func _on_popup_index_pressed(idx: int) -> void:
	var is_checked: bool = get_popup().is_item_checked(idx)
	get_popup().set_item_checked(idx, not is_checked)
	emit_signal(
		"item_pressed",
		get_popup().get_item_text(idx),
		get_popup().is_item_checked(idx)
	)
