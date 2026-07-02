extends CanvasLayer

# In-game pause menu. This replaces the old prototype overlay with real menu
# panels while preserving debug keys, scenery switching, player reset, and prop
# reset behavior.

@export var camera_path: NodePath
@export var ambience_path: NodePath

var _camera: Node
var _ambience: Node
var _root: Control
var _list: VBoxContainer
var _current_panel: String = "pause"


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_camera = get_node_or_null(camera_path)
	_ambience = get_node_or_null(ambience_path)
	SettingsManager.register_camera(_camera)
	SettingsManager.register_ambience(_ambience)
	SettingsManager.apply_all()
	_build_shell()
	_hide_menu()


func _exit_tree() -> void:
	SettingsManager.clear_camera(_camera)
	SettingsManager.clear_ambience(_ambience)


func _unhandled_input(event: InputEvent) -> void:
	var key_event: InputEventKey = event as InputEventKey
	if key_event == null or not key_event.pressed or key_event.echo:
		return

	if key_event.keycode == KEY_ESCAPE:
		_handle_escape()
		get_viewport().set_input_as_handled()
	elif key_event.keycode == KEY_T:
		_reset_props()
		get_viewport().set_input_as_handled()


func _handle_escape() -> void:
	if not _root.visible:
		_show_pause_panel()
		return

	if _current_panel == "pause":
		_resume_game()
	else:
		_show_pause_panel()


func _build_shell() -> void:
	_root = Control.new()
	_root.set_anchors_preset(Control.PRESET_FULL_RECT)
	_root.process_mode = Node.PROCESS_MODE_ALWAYS
	_root.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(_root)

	var shade := ColorRect.new()
	shade.set_anchors_preset(Control.PRESET_FULL_RECT)
	shade.color = Color(0.0, 0.0, 0.0, 0.58)
	shade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_root.add_child(shade)

	var panel := PanelContainer.new()
	panel.anchor_left = 0.5
	panel.anchor_right = 0.5
	panel.anchor_top = 0.5
	panel.anchor_bottom = 0.5
	panel.offset_left = -250.0
	panel.offset_right = 250.0
	panel.offset_top = -315.0
	panel.offset_bottom = 315.0
	FlipflopUIStyle.apply_panel(panel)
	_root.add_child(panel)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 24)
	margin.add_theme_constant_override("margin_right", 24)
	margin.add_theme_constant_override("margin_top", 24)
	margin.add_theme_constant_override("margin_bottom", 24)
	panel.add_child(margin)

	_list = VBoxContainer.new()
	_list.add_theme_constant_override("separation", 10)
	margin.add_child(_list)


func _show_pause_panel() -> void:
	_current_panel = "pause"
	get_tree().paused = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	_hide_help_overlay()
	_root.visible = true
	_reset_list("Paused")
	_add_button("Resume", _resume_game)
	_add_button("Restart Current Scenery", _restart_current_scenery)
	_add_button("Scenery Select", _show_scenery_panel)
	_add_button("Options", _show_options_panel)
	_add_button("Controls", _show_controls_panel)
	_add_button("Main Menu", _go_to_main_menu)
	_add_button("Quit to Desktop", _quit_to_desktop)


func _show_scenery_panel() -> void:
	_current_panel = "scenery"
	get_tree().paused = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	_root.visible = true
	_reset_list("Sceneries")
	_add_scenery_button(FlipflopUIManager.DESERTED_ISLAND_ID)
	_add_scenery_button(FlipflopUIManager.RESORT_POOL_ID)
	_add_scenery_button(FlipflopUIManager.BOARDWALK_ID)
	_add_scenery_button(FlipflopUIManager.CRUISE_SHIP_DECK_ID)
	_add_scenery_button(FlipflopUIManager.LOCKER_ROOM_ID)
	_add_spacer(8.0)
	_add_button("Back", _show_pause_panel)


func _show_options_panel() -> void:
	_current_panel = "options"
	get_tree().paused = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	_root.visible = true
	_reset_list("Options")
	_add_slider("Master Volume", 0.0, 1.0, 0.01, SettingsManager.master_volume, _on_master_volume_changed)
	_add_slider("SFX Volume", 0.0, 1.0, 0.01, SettingsManager.sfx_volume, _on_sfx_volume_changed)
	_add_slider("Ambience Volume", 0.0, 1.0, 0.01, SettingsManager.ambience_volume, _on_ambience_volume_changed)
	_add_slider("Mouse Sensitivity", 0.001, 0.01, 0.0001, SettingsManager.mouse_sensitivity, _on_mouse_sensitivity_changed)
	_add_check_box("Invert Y", SettingsManager.invert_y, _on_invert_y_toggled)
	_add_check_box("Camera Shake", SettingsManager.camera_shake_enabled, _on_camera_shake_toggled)
	_add_check_box("Day/Night Cycle", SettingsManager.day_night_enabled, _on_day_night_toggled)
	_add_check_box("Fullscreen", SettingsManager.fullscreen_enabled, _on_fullscreen_toggled)
	_add_spacer(8.0)
	_add_button("Reset Defaults", _on_reset_defaults_pressed)
	_add_button("Back", _show_pause_panel)


func _show_controls_panel() -> void:
	_current_panel = "controls"
	get_tree().paused = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	_root.visible = true
	_reset_list("Controls")

	_add_section_line("Movement")
	_add_text_line("WASD: Move")
	_add_text_line("Space: Hop / flap")
	_add_text_line("Shift: Boost")
	_add_section_line("Camera")
	_add_text_line("Mouse: Rotate camera")
	_add_text_line("Scroll Wheel: Zoom")
	_add_section_line("Actions")
	_add_text_line("Left Click: Slap / lunge")
	_add_text_line("R: Reset flipflop")
	_add_section_line("Utility")
	_add_text_line("F1: Debug panel")
	_add_text_line("F2: Movement preset")
	_add_text_line("H: Help overlay")
	_add_text_line("P: Photo mode")
	_add_text_line("Escape: Pause / back")

	_add_spacer(10.0)
	_add_button("Back", _show_pause_panel)


func _reset_list(title: String) -> void:
	for child: Node in _list.get_children():
		_list.remove_child(child)
		child.free()

	var title_label := Label.new()
	title_label.text = title
	FlipflopUIStyle.style_title(title_label)
	_list.add_child(title_label)
	_add_spacer(6.0)


func _add_scenery_button(scenery_id: String) -> void:
	var label: String = FlipflopUIManager.get_scenery_display_name(scenery_id)
	_add_button(label, _load_scenery_from_pause.bind(scenery_id))


func _add_button(text: String, callback: Callable) -> Button:
	var button := Button.new()
	button.text = text
	FlipflopUIStyle.apply_button(button, 42.0)
	button.pressed.connect(callback)
	_list.add_child(button)
	return button


func _add_slider(
	label_text: String,
	min_value: float,
	max_value: float,
	step: float,
	value: float,
	callback: Callable
) -> HSlider:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 12)
	_list.add_child(row)

	var label := Label.new()
	label.text = label_text
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	FlipflopUIStyle.style_body(label, 16)
	row.add_child(label)

	var value_label := Label.new()
	value_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	value_label.custom_minimum_size = Vector2(92.0, 0.0)
	FlipflopUIStyle.style_muted(value_label, 15)
	_update_slider_value_label(value_label, label_text, value)
	row.add_child(value_label)

	var slider := HSlider.new()
	slider.min_value = min_value
	slider.max_value = max_value
	slider.step = step
	slider.value = value
	slider.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	slider.value_changed.connect(
		_on_slider_value_changed.bind(value_label, label_text, callback)
	)
	_list.add_child(slider)
	return slider


func _add_check_box(text: String, value: bool, callback: Callable) -> CheckBox:
	var check_box := CheckBox.new()
	check_box.text = text
	check_box.button_pressed = value
	FlipflopUIStyle.style_body(check_box, 16)
	check_box.toggled.connect(callback)
	_list.add_child(check_box)
	return check_box


func _add_section_line(text: String) -> void:
	var label := Label.new()
	label.text = text
	FlipflopUIStyle.style_section(label)
	_list.add_child(label)


func _add_text_line(text: String) -> void:
	var label := Label.new()
	label.text = text
	FlipflopUIStyle.style_body(label)
	_list.add_child(label)


func _add_spacer(height: float) -> void:
	var spacer := Control.new()
	spacer.custom_minimum_size = Vector2(0.0, height)
	_list.add_child(spacer)


func _on_slider_value_changed(
	value: float,
	value_label: Label,
	label_text: String,
	callback: Callable
) -> void:
	_update_slider_value_label(value_label, label_text, value)
	callback.call(value)


func _update_slider_value_label(value_label: Label, label_text: String, value: float) -> void:
	if label_text.to_lower().contains("sensitivity"):
		value_label.text = "%.4f" % value
	else:
		value_label.text = "%d%%" % int(round(value * 100.0))


func _hide_menu() -> void:
	_root.visible = false


func _hide_help_overlay() -> void:
	var help_overlay: Node = get_tree().get_first_node_in_group("help_overlay")
	if help_overlay != null and help_overlay.has_method("hide_overlay"):
		help_overlay.call("hide_overlay")


func _resume_game() -> void:
	get_tree().paused = false
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	_hide_menu()


func _restart_current_scenery() -> void:
	var scenery_manager: Node = get_tree().get_first_node_in_group("scenery_manager")
	if scenery_manager != null and scenery_manager.has_method("get_current_scenery_id") and scenery_manager.has_method("load_scenery"):
		var current_id: String = String(scenery_manager.call("get_current_scenery_id"))
		if not current_id.is_empty():
			scenery_manager.call("load_scenery", current_id)

	_resume_game()


func _load_scenery_from_pause(scenery_id: String) -> void:
	var scenery_manager: Node = get_tree().get_first_node_in_group("scenery_manager")
	if scenery_manager != null and scenery_manager.has_method("load_scenery"):
		scenery_manager.call("load_scenery", scenery_id)

	_resume_game()


func _reset_props() -> void:
	var scenery_manager: Node = get_tree().get_first_node_in_group("scenery_manager")
	if scenery_manager != null and scenery_manager.has_method("reset_current_scenery_props"):
		scenery_manager.call("reset_current_scenery_props")


func _go_to_main_menu() -> void:
	SettingsManager.save_settings()
	FlipflopUIManager.load_main_menu(get_tree())


func _quit_to_desktop() -> void:
	get_tree().quit()


func _on_master_volume_changed(value: float) -> void:
	SettingsManager.set_master_volume(value)


func _on_sfx_volume_changed(value: float) -> void:
	SettingsManager.set_sfx_volume(value)


func _on_ambience_volume_changed(value: float) -> void:
	SettingsManager.set_ambience_volume(value)


func _on_mouse_sensitivity_changed(value: float) -> void:
	SettingsManager.set_mouse_sensitivity(value)


func _on_invert_y_toggled(enabled: bool) -> void:
	SettingsManager.set_invert_y(enabled)


func _on_camera_shake_toggled(enabled: bool) -> void:
	SettingsManager.set_camera_shake_enabled(enabled)


func _on_day_night_toggled(enabled: bool) -> void:
	SettingsManager.set_day_night_enabled(enabled)


func _on_fullscreen_toggled(enabled: bool) -> void:
	SettingsManager.set_fullscreen_enabled(enabled)


func _on_reset_defaults_pressed() -> void:
	SettingsManager.reset_to_defaults()
	_show_options_panel()
