signal color_chosen(color)

extends Control

onready var color_picker: ColorPicker = $V/ColorPicker
onready var add_color_button: Button = $V/AddColor
onready var color_preview: ColorRect = $V/AddColor/ColorRect

func _ready():
	add_color_button.connect("pressed", self, "_on_addcolor_pressed")
	color_picker.connect("color_changed", self, "_on_colorpicker_color_changed")

func _on_addcolor_pressed() -> void:
	emit_signal("color_chosen", color_picker.color)

func _on_colorpicker_color_changed(color: Color) -> void:
	color_preview.color = color
