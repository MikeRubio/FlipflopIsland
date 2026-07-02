extends Control

# Read-only controls reference screen.


func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	_build_ui()


func _unhandled_input(event: InputEvent) -> void:
	var key_event: InputEventKey = event as InputEventKey
	if key_event == null or not key_event.pressed or key_event.echo:
		return

	if key_event.keycode == KEY_ESCAPE:
		_on_back_pressed()
		get_viewport().set_input_as_handled()


func _build_ui() -> void:
	add_child(_make_background())

	var panel: PanelContainer = _make_panel()
	add_child(panel)

	var list: VBoxContainer = _make_list(panel)
	_add_title(list, "Controls")

	_add_section(list, "Movement")
	_add_control_line(list, "WASD: Move")
	_add_control_line(list, "Space: Hop / flap")
	_add_control_line(list, "Shift: Boost")

	_add_section(list, "Camera")
	_add_control_line(list, "Mouse: Rotate camera")
	_add_control_line(list, "Scroll Wheel: Zoom")

	_add_section(list, "Actions")
	_add_control_line(list, "Left Click: Slap / lunge")
	_add_control_line(list, "R: Reset flipflop")

	_add_section(list, "Utility")
	_add_control_line(list, "F1: Debug panel")
	_add_control_line(list, "F2: Movement preset")
	_add_control_line(list, "H: Help overlay")
	_add_control_line(list, "P: Photo mode")
	_add_control_line(list, "Escape: Pause / back")

	_add_spacer(list, 12.0)
	_add_button(list, "Back", _on_back_pressed)


func _make_background() -> ColorRect:
	return FlipflopUIStyle.make_background()


func _make_panel() -> PanelContainer:
	var panel := PanelContainer.new()
	panel.anchor_left = 0.5
	panel.anchor_right = 0.5
	panel.anchor_top = 0.5
	panel.anchor_bottom = 0.5
	panel.offset_left = -250.0
	panel.offset_right = 250.0
	panel.offset_top = -330.0
	panel.offset_bottom = 330.0
	FlipflopUIStyle.apply_panel(panel)
	return panel


func _make_list(panel: PanelContainer) -> VBoxContainer:
	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 24)
	margin.add_theme_constant_override("margin_right", 24)
	margin.add_theme_constant_override("margin_top", 24)
	margin.add_theme_constant_override("margin_bottom", 24)
	panel.add_child(margin)

	var list := VBoxContainer.new()
	list.add_theme_constant_override("separation", 9)
	margin.add_child(list)
	return list


func _add_title(list: VBoxContainer, text: String) -> void:
	var label := Label.new()
	label.text = text
	FlipflopUIStyle.style_title(label)
	list.add_child(label)
	_add_spacer(list, 6.0)


func _add_section(list: VBoxContainer, text: String) -> void:
	var label := Label.new()
	label.text = text
	FlipflopUIStyle.style_section(label)
	list.add_child(label)


func _add_control_line(list: VBoxContainer, text: String) -> void:
	var label := Label.new()
	label.text = text
	FlipflopUIStyle.style_body(label)
	list.add_child(label)


func _add_button(list: VBoxContainer, text: String, callback: Callable) -> Button:
	var button := Button.new()
	button.text = text
	FlipflopUIStyle.apply_button(button, 42.0)
	button.pressed.connect(callback)
	list.add_child(button)
	return button


func _add_spacer(list: VBoxContainer, height: float) -> void:
	var spacer := Control.new()
	spacer.custom_minimum_size = Vector2(0.0, height)
	list.add_child(spacer)


func _on_back_pressed() -> void:
	get_tree().change_scene_to_file(FlipflopUIManager.MAIN_MENU_SCENE_PATH)
