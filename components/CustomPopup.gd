## A Popup with more control over how it hides and autopopulates itself. Meant to be extended.
class_name CustomPopup

signal setting_applied(seting_data)

extends Control

# String passed with setting_applied signal, changes based on context.
export var setting_data := ""

export var first_focus: NodePath

onready var option = get_node_or_null("Option")
onready var line = get_node_or_null("LineEdit")
onready var ok = get_node_or_null("OK")
onready var cancel = get_node_or_null("Cancel")
onready var x = get_node_or_null("X")

func _unhandled_input(event: InputEvent):
	if not visible:
		return
	if event.is_action_pressed("popup_ok"):
		emit_line_setting()
	if event.is_action_pressed("popup_cancel"):
		hide()
		clear_field()

func popup() -> void:
	show()
	var ff = get_node_or_null(first_focus)
	if ff is Control:
		ff.grab_focus()

func _ready():
	if x:
		x.connect("pressed", self, "hide")
	if ok:
		ok.connect("pressed", self, "emit_line_setting")
	if cancel:
		cancel.connect("pressed", self, "hide")
	if option:
		option.connect("item_selected", self, "set_setting_data_from_idx")
	if line:
		line.connect("text_changed", self, "set_setting_data")
		line.connect("text_entered", self, "confirm_setting_data")

func set_setting_data(data:String) -> void:
	setting_data = data

func confirm_setting_data(_text:String) -> void:
	if not line:
		return
	emit_line_setting()

func set_setting_data_from_idx(i:int) -> void:
	if not option:
		return
	setting_data = option.get_item_text(i)

func emit_line_setting() -> void:
	if not line:
		hide()
		return
	emit_signal("setting_applied", line.text)
	hide()
	clear_field()

func clear_field() -> void:
	if line:
		line.text = ""
