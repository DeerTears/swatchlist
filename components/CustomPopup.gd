## A Popup with more control over how it hides and autopopulates itself. Meant to be extended.
class_name CustomPopup

signal setting_applied(seting_data)

extends Control

# String passed with setting_applied signal, changes based on context.
export var setting_data := ""

# Looks to resources saved in res://shortcuts/ to determine global actions...wait I could've just used Input Map. Oh well, next time.
export var enter_shortcut: ShortCut
export var escape_shortcut: ShortCut

onready var option = get_node_or_null("Option")
onready var line = get_node_or_null("LineEdit")

func _unhandled_input(event: InputEvent):
	if not visible:
		return
	if event.shortcut_match(enter_shortcut.get_shortcut()):
		apply_setting(setting_data)
	if event.shortcut_match(escape_shortcut.get_shortcut()):
		hide()
		clear_field()


func _ready():
	var x = get_node_or_null("X")
	var ok = get_node_or_null("OK")
	var cancel = get_node_or_null("Cancel")
	if x:
		x.connect("pressed", self, "hide")
	if ok:
		ok.connect("pressed", self, "apply_setting", [setting_data])
	if cancel:
		cancel.connect("pressed", self, "hide")
	if option:
		option.connect("item_selected", self, "set_setting_data_from_idx")
	if line:
		line.connect("text_entered", self, "set_setting_data_from_string")


func set_setting_data_from_string(text:String) -> void:
	if not line:
		return
	setting_data = line.text
	apply_setting(line.text)


func set_setting_data_from_idx(i:int) -> void:
	if not option:
		return
	setting_data = option.get_item_text(i)


func apply_setting(data) -> void:
	emit_signal("setting_applied", data)
	hide()
	clear_field()


func clear_field() -> void:
	if line:
		line.text = ""
