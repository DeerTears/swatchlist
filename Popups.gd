## Recieves signals from various popup children and signals up to the Main program.
signal setting_applied(data)

extends Control

func _ready():
	for child in get_children():
		if child is CustomPopup:
			child.connect("setting_applied", self, "apply_setting")

func apply_setting(data: String) -> void:
	emit_signal("setting_applied", data)
