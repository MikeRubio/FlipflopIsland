extends Control

# Standalone options menu used from the main menu.
# Values are runtime-only and live in the SettingsManager autoload.


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
	_add_title(list, "Options")
	_add_slider(list, "Master Volume", 0.0, 1.0, 0.01, SettingsManager.master_volume, _on_master_volume_changed)
	_add_slider(list, "SFX Volume", 0.0, 1.0, 0.01, SettingsManager.sfx_volume, _on_sfx_volume_changed)
	_add_slider(list, "Ambience Volume", 0.0, 1.0, 0.01, SettingsManager.ambience_volume, _on_ambience_volume_changed)
	_add_slider(list, "Mouse Sensitivity", 0.001, 0.01, 0.0001, SettingsManager.mouse_sensitivity, _on_mouse_sensitivity_changed)
	_add_check_box(list, "Invert Y", SettingsManager.invert_y, _on_invert_y_toggled)
	_add_check_box(list, "Camera Shake", SettingsManager.camera_shake_enabled, _on_camera_shake_toggled)
	_add_check_box(list, "Day/Night Cycle", SettingsManager.day_night_enabled, _on_day_night_toggled)
	_add_check_box(list, "Fullscreen", SettingsManager.fullscreen_enabled, _on_fullscreen_toggled)
	_add_spacer(list, 8.0)
	_add_button(list, "Reset Defaults", _on_reset_defaults_pressed)
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
	panel.offset_top = -310.0
	panel.offset_bottom = 310.0
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
	list.add_theme_constant_override("separation", 8)
	margin.add_child(list)
	return list


func _add_title(list: VBoxContainer, text: String) -> void:
	var label := Label.new()
	label.text = text
	FlipflopUIStyle.style_title(label)
	list.add_child(label)
	_add_spacer(list, 6.0)


func _add_slider(
	list: VBoxContainer,
	label_text: String,
	min_value: float,
	max_value: float,
	step: float,
	value: float,
	callback: Callable
) -> HSlider:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 12)
	list.add_child(row)

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
	list.add_child(slider)
	return slider


func _add_check_box(list: VBoxContainer, text: String, value: bool, callback: Callable) -> CheckBox:
	var check_box := CheckBox.new()
	check_box.text = text
	check_box.button_pressed = value
	FlipflopUIStyle.style_body(check_box, 16)
	check_box.toggled.connect(callback)
	list.add_child(check_box)
	return check_box


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
	get_tree().reload_current_scene()


func _on_back_pressed() -> void:
	SettingsManager.save_settings()
	get_tree().change_scene_to_file(FlipflopUIManager.MAIN_MENU_SCENE_PATH)
