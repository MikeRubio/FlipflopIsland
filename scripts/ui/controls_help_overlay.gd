extends CanvasLayer

# Lightweight in-game controls reference.
# This is only instanced in the gameplay scene, so the main menu keeps using
# its normal Controls Menu screen.

var _root: Control
var _panel: PanelContainer


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	add_to_group("help_overlay")
	_build_overlay()
	visible = false


func _unhandled_input(event: InputEvent) -> void:
	var key_event: InputEventKey = event as InputEventKey
	if key_event == null or not key_event.pressed or key_event.echo:
		return

	if key_event.keycode == KEY_H:
		if get_tree().paused and not visible:
			return

		_toggle_overlay()
		get_viewport().set_input_as_handled()


func _build_overlay() -> void:
	_root = Control.new()
	_root.set_anchors_preset(Control.PRESET_FULL_RECT)
	_root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_root)

	_panel = PanelContainer.new()
	_panel.anchor_left = 1.0
	_panel.anchor_right = 1.0
	_panel.anchor_top = 0.0
	_panel.anchor_bottom = 0.0
	_panel.offset_left = -390.0
	_panel.offset_right = -24.0
	_panel.offset_top = 84.0
	_panel.offset_bottom = 500.0
	_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	FlipflopUIStyle.apply_panel(_panel, 0.78)
	_root.add_child(_panel)

	var margin := MarginContainer.new()
	margin.mouse_filter = Control.MOUSE_FILTER_IGNORE
	margin.add_theme_constant_override("margin_left", 20)
	margin.add_theme_constant_override("margin_right", 20)
	margin.add_theme_constant_override("margin_top", 18)
	margin.add_theme_constant_override("margin_bottom", 18)
	_panel.add_child(margin)

	var list := VBoxContainer.new()
	list.mouse_filter = Control.MOUSE_FILTER_IGNORE
	list.add_theme_constant_override("separation", 8)
	margin.add_child(list)

	_add_title(list, "Controls")

	var controls: Array[String] = [
		"WASD: Move",
		"Mouse: Rotate camera",
		"Scroll Wheel: Zoom",
		"Space: Hop / flap",
		"Shift: Boost",
		"Left Click: Slap / lunge",
		"R: Reset flipflop",
		"F1: Debug panel",
		"F2: Movement preset",
		"H: Toggle help",
		"Escape: Pause",
	]

	for control_text: String in controls:
		_add_control_line(list, control_text)

	_add_spacer(list, 8.0)
	_add_hint_line(list, "Press H to close")


func _toggle_overlay() -> void:
	visible = not visible


func hide_overlay() -> void:
	visible = false


func _add_title(list: VBoxContainer, text: String) -> void:
	var label := Label.new()
	label.text = text
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	FlipflopUIStyle.style_title(label, 26)
	list.add_child(label)
	_add_spacer(list, 4.0)


func _add_control_line(list: VBoxContainer, text: String) -> void:
	var label := Label.new()
	label.text = text
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	FlipflopUIStyle.style_body(label, 16)
	list.add_child(label)


func _add_hint_line(list: VBoxContainer, text: String) -> void:
	var label := Label.new()
	label.text = text
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	FlipflopUIStyle.style_muted(label, 14)
	list.add_child(label)


func _add_spacer(list: VBoxContainer, height: float) -> void:
	var spacer := Control.new()
	spacer.custom_minimum_size = Vector2(0.0, height)
	spacer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	list.add_child(spacer)

