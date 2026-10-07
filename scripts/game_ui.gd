extends CanvasLayer

signal restart_requested
signal quit_requested

var objective_label: Label
var count_label: Label
var prompt_label: Label
var dialogue_panel: PanelContainer
var dialogue_label: Label
var completion_panel: ColorRect


func _ready() -> void:
	var root := Control.new()
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(root)
	var quest_panel := PanelContainer.new()
	quest_panel.position = Vector2(24, 24)
	quest_panel.size = Vector2(420, 145)
	quest_panel.add_theme_stylebox_override("panel", _panel_style())
	root.add_child(quest_panel)
	var quest_box := VBoxContainer.new()
	quest_box.add_theme_constant_override("separation", 8)
	quest_panel.add_child(quest_box)
	quest_box.add_child(_label("FIELD NOTES  /  THE HERBALIST", 16, Color("d1bf86")))
	objective_label = _label("", 21)
	quest_box.add_child(objective_label)
	count_label = _label("", 22, Color("b8d78d"))
	quest_box.add_child(count_label)
	var controls := _label("WASD / Arrows  ·  Move     E  ·  Interact / Continue", 17)
	controls.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_LEFT)
	controls.position = Vector2(24, -40)
	root.add_child(controls)
	prompt_label = _label("", 22, Color("f0d893"))
	prompt_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	prompt_label.set_anchors_and_offsets_preset(Control.PRESET_CENTER_BOTTOM)
	prompt_label.position = Vector2(-280, -88)
	prompt_label.size = Vector2(560, 40)
	root.add_child(prompt_label)
	dialogue_panel = PanelContainer.new()
	dialogue_panel.set_anchors_and_offsets_preset(Control.PRESET_CENTER_BOTTOM)
	dialogue_panel.position = Vector2(-450, -240)
	dialogue_panel.size = Vector2(900, 135)
	dialogue_panel.add_theme_stylebox_override("panel", _panel_style())
	root.add_child(dialogue_panel)
	var dialogue_box := VBoxContainer.new()
	dialogue_box.add_theme_constant_override("separation", 12)
	dialogue_panel.add_child(dialogue_box)
	dialogue_box.add_child(_label("THE HERBALIST", 16, Color("d1bf86")))
	dialogue_label = _label("", 24)
	dialogue_box.add_child(dialogue_label)
	dialogue_box.add_child(_label("E  ·  Continue", 16, Color("b8d78d")))
	dialogue_panel.hide()
	completion_panel = ColorRect.new()
	completion_panel.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	completion_panel.color = Color(0.06, 0.12, 0.1, 0.93)
	root.add_child(completion_panel)
	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	completion_panel.add_child(center)
	var complete_box := VBoxContainer.new()
	complete_box.add_theme_constant_override("separation", 24)
	center.add_child(complete_box)
	for text in ["QUEST COMPLETE", "You collected the medicinal herbs.", "Thank you for playing."]:
		var label := _label(text, 36 if text == "QUEST COMPLETE" else 22)
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		complete_box.add_child(label)
	var restart := Button.new()
	restart.text = "Restart  [R]"
	restart.custom_minimum_size = Vector2(300, 52)
	restart.add_theme_font_size_override("font_size", 22)
	restart.pressed.connect(func(): restart_requested.emit())
	complete_box.add_child(restart)
	var exit_button := Button.new()
	exit_button.text = "Exit  [Esc]"
	exit_button.custom_minimum_size = Vector2(300, 48)
	exit_button.pressed.connect(func(): quit_requested.emit())
	complete_box.add_child(exit_button)
	completion_panel.hide()


func _label(text: String, font_size: int, color: Color = Color("ece9d6")) -> Label:
	var label := Label.new()
	label.text = text
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.5))
	label.add_theme_constant_override("shadow_offset_y", 1)
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return label


func _panel_style() -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.08, 0.16, 0.12, 0.94)
	style.border_color = Color("718368")
	style.set_border_width_all(1)
	style.set_corner_radius_all(8)
	style.content_margin_left = 20
	style.content_margin_right = 20
	style.content_margin_top = 16
	style.content_margin_bottom = 16
	return style


func update_quest(objective: String, count: int, required: int) -> void:
	objective_label.text = objective
	count_label.text = "Herbs: %d / %d" % [mini(count, required), required]


func set_prompt(text: String) -> void:
	prompt_label.text = text


func show_dialogue(text: String) -> void:
	dialogue_label.text = text
	dialogue_panel.show()


func hide_dialogue() -> void:
	dialogue_panel.hide()


func show_completion() -> void:
	completion_panel.show()