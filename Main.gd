# main functionality left todo:
"""
Remove: click "delete mode" and click on swatch.
Move: Click and hold on swatch, it will automatically reposition itself along the list while the mouse is held down. Release to confirm current position. Show users their drop targets, let users increase swatch/target size.
Edit: Double click a swatch to open colour dialog menu.
"""
# nice to have:

## subpalettes and custom resource saving
# 1. Connect updates from the swatches changing to a Resource updated in real-time
# 2. Use that resource to store subpalette resources and names on colours
# 3. Save this resource with subpalettes stored

extends Panel

const IMAGE_WIDTH := 2
const IMAGE_HEIGHT := 2

const DEFAULT_SWATCH_SIZE := 64

export var include_hash_in_copy := false
export var copy_command: ShortCut
export var paste_command: ShortCut
export var new_command: ShortCut
export var open_command: ShortCut
export var save_command: ShortCut
export var save_as_command: ShortCut

## How large in pixels the swatch squares are displayed.
# Todo: make this affect TextureButton size.
var swatch_size := 64

var current_filename := "Untitled" setget set_current_filename, get_current_filename

# Scenes
onready var swatch_template: PackedScene = preload("res://components/Swatch.tscn")

# Top of Application
onready var toolbar_buttons: HBoxContainer = $C/Toolbar/Buttons
onready var sub_palette_selector_button: OptionButton = $C/SubPaletteSelector

# Workspace
onready var workspace: PanelContainer = $C/Split/Workspace

onready var picker_panel := $C/Split/Split/Split/PickerPanel

# Swatches
onready var swatches_scroll_container: ScrollContainer = $C/Split/Workspace/C/Scroll
onready var swatches_list: GridContainer = $C/Split/Workspace/C/Scroll/Colors

# Warnings
onready var warnings: PanelContainer = $C/Split/Split/Split/Warnings
onready var warnings_label: RichTextLabel = $C/Split/Split/Split/Warnings/RichLabel
onready var warnings_tween: Tween = $C/Split/Split/Split/Warnings/Tween

func _ready() -> void:
	$Popups.connect("setting_applied", self, "_on_popup_setting_applied")
	$C/Split/Split/Split/PickerPanel.connect("color_chosen", self, "add_new_color")
	for menu_button in toolbar_buttons.get_children():
		if menu_button is MenuButton:
			menu_button.connect("item_pressed", self, "_on_toolbar_index_pressed")
	
	get_tree().connect("files_dropped", self, "_on_files_dropped")


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed:
		if event.shortcut_match(save_command.get_shortcut(), true):
			attempt_save(false)
		elif event.shortcut_match(save_as_command.get_shortcut(), true):
			attempt_save(true)
		elif event.shortcut_match(new_command.get_shortcut(), true):
			new()
		elif event.shortcut_match(open_command.get_shortcut(), true):
			open()
		elif event.shortcut_match(copy_command.get_shortcut(), true):
			copy_current_color()
#		elif event.shortcut_match(paste_command.get_shortcut(), true):
#			paste_color()


# Todo: Allow dropping text files and opening Import dialog
func _on_files_dropped(_files: PoolStringArray, _screen: int) -> void:
	send_warning("Dropped files are not yet fully supported.")


func _on_popup_setting_applied(data: String) -> void:
	set_current_filename(data)


func _on_swatch_pressed(color_hex: String) -> void:
	var button_mask = Input.get_mouse_button_mask()
	match button_mask:
		BUTTON_MASK_LEFT:
			OS.set_clipboard("#" + color_hex if include_hash_in_copy else color_hex)
		# todo: turn this into a drag and drop starter
		BUTTON_MASK_RIGHT:
			# todo: refactor this into an erase swatch function, so it can be a result of a toggleable "delete swatch" left-click mode
			swatches_list.remove_child(swatches_list.get_node_or_null("./%s" % [color_hex]))


func _on_toolbar_index_pressed(button_text: String, is_checked: bool) -> void:
	match button_text:
		# File
		"New":
			new()
		"Rename":
			rename(false)
		"Open":
			open()
		"Save":
			attempt_save(false)
		"Save As":
			attempt_save(true)
		"Quit":
			get_tree().quit()
		# View
		"Show Workspace":
			workspace.visible = is_checked
			if not is_checked:
				send_warning("Go to View -> Show Workspace to turn the workspace back on.")
			else:
				send_warning("")
		"Show Subpalette Selector":
			sub_palette_selector_button.visible = is_checked
		"Show Color Picker":
			picker_panel.visible = is_checked
			if not is_checked:
				send_warning("Go to View -> Show Color Picker to turn the picker back on.")
			else:
				send_warning("")
		"Show Warnings":
			warnings.visible = is_checked
			if is_checked:
				send_warning("Whew, it's dark in there. Thanks for bringing me back!")
		# Help
		"About":
			$Popups/About.popup()
		"Wiki...":
			OS.shell_open("https://github.com/deertears/swatchlist/wiki")
		"See my other tools...":
			OS.shell_open("https://github.com/deertears")
		"Report Bugs...":
			OS.shell_open("https://github.com/DeerTears/swatchlist/issues/new")
		"Suggest Features...":
			OS.shell_open("https://github.com/DeerTears/swatchlist/issues/new")


func set_current_filename(new_name: String) -> void:
	current_filename = new_name
	OS.set_window_title(new_name)


func get_current_filename() -> String:
	return current_filename


func add_new_color(color) -> void:
	for swatch in swatches_list.get_children():
		if swatch.name.matchn(color.to_html(false)):
			send_warning("This color is already in the list.")
			var existing_swatch = swatches_list.get_node_or_null("%s" % color.to_html(false))
			if existing_swatch:
				existing_swatch.grab_focus()
			else:
				send_error("Thought %s was an existing swatch, but couldn't find .../Scroll/Colors/%s in the SceneTree.)" % [color.to_html(false), color.to_html(false)])
			return
	send_warning("")
	var new_texture := ImageTexture.new()
	new_texture.create_from_image(generate_color_image(color))
	new_texture.flags = 0
	var new_button = swatch_template.instance()
	new_button.name = color.to_html(false)
	new_button.icon = new_texture
	new_button.rect_min_size = Vector2(swatch_size, swatch_size)
	new_button.connect("pressed", self, "_on_swatch_pressed", [new_button.name])
	swatches_list.add_child(new_button, true)
	yield(get_tree(), "idle_frame")
	yield(get_tree(), "idle_frame")
	swatches_scroll_container.scroll_vertical = 99999


func clear_color_list() -> void:
	for child in swatches_list.get_children():
		child.queue_free()


func copy_current_color() -> void:
	send_warning("Copying from keyboard is not implemented yet")


func generate_color_image(color: Color) -> Image:
	var img = Image.new()
	img.create(IMAGE_WIDTH, IMAGE_HEIGHT, false, Image.FORMAT_RGBA8)
	img.lock()
	for y in range(0, IMAGE_HEIGHT):
		for x in range(0, IMAGE_WIDTH):
			img.set_pixel(x, y, color)
	img.unlock()
	return img


func get_swatches_as_text() -> String:
	var result := ""
	var iterator := 0
	var swatch_total := swatches_list.get_child_count()
	for swatch in swatches_list.get_children():
		result += swatch.name
		if iterator <= swatch_total - 2:
			result += "\n"
			iterator += 1
	return result


func open() -> void:
	OS.shell_open(ProjectSettings.globalize_path("user://"))


func new() -> void:
	$Popups/NewDialog.popup()
	$Popups/NewDialog.connect("confirmed", self, "reset_all_swatches")


#func paste_color() -> void:
#	var paste_text: String = OS.get_clipboard().strip_escapes()
#	paste_text = paste_text.trim_prefix("#") # valid_hex won't take hashes
#	if not paste_text.is_valid_hex_number(false):
#		send_warning("Clipboard pastes must be a hex number.")
#		return
#	if paste_text.length() > 6:
#		paste_text = paste_text.substr(0, 6)
#	var paste_color := Color(paste_text)
#	paste_color.a = 1.0
#	add_new_color(paste_color)


func rename(has_to_save_after_rename: bool) -> void:
	$Popups/Rename.popup()
	if has_to_save_after_rename:
		yield($Popups, "setting_applied")
		save()


func reset_all_swatches() -> void:
	for child in swatches_list.get_children():
		child.queue_free()
	set_current_filename("Untitled")


func attempt_save(as_new_file: bool) -> void:
	var d: Directory = Directory.new()
	if d.file_exists(
		ProjectSettings.globalize_path(
			"user://%s.swatchlist" % [current_filename]
		)
	):
		if as_new_file:
			send_warning("This file exists, saving as.")
			save_as()
		else:
			send_warning("This file exists, saving.")
			save()
	else:
		send_warning("This file doesn't exist, saving as.")
		save_as()


func save() -> void:
	var file := File.new()
	file.open("user://%s.swatchlist" % [current_filename], File.WRITE)
	file.store_string(get_swatches_as_text())
	file.close()


func save_as() -> void:
	if current_filename == "Untitled":
		rename(true)
	else:
		save()


func send_warning(warning:String) -> void:
	warnings_label.text = warning
	warnings_tween.stop_all()
	warnings_tween.interpolate_property(warnings_label, "percent_visible", 0.0, 1.0, 1.0, Tween.TRANS_LINEAR)
	warnings_tween.start()


# Todo: make errors stand out visually
func send_error(error: String) -> void:
	warnings_label.text = error
	warnings_tween.stop_all()
	warnings_tween.interpolate_property(warnings_label, "percent_visible", 0.0, 1.0, 1.0, Tween.TRANS_LINEAR)
	warnings_tween.start()
