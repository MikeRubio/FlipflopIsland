extends CanvasLayer

# Prototype menus and settings for Flipflop Island.
# This is intentionally simple: no progression, no profiles, no Steam features.
# Future launch/menu work should replace this with a proper scene flow while
# keeping the settings and reset calls routed through the same manager methods.

const SETTINGS_PATH := "user://flipflop_settings.cfg"
const SFX_BUS := "SFX"
const AMBIENCE_BUS := "Ambience"

@export var player_path: NodePath
@export var camera_path: NodePath
@export var ambience_path: NodePath

var _player: Node
var _camera: Node
var _ambience: Node

var _root: Control
var _main_menu: Control
var _pause_menu: Control
var _options_menu: Control
var _help_overlay: Control

var _master_volume: float = 0.85
var _sfx_volume: float = 0.85
var _ambience_volume: float = 0.75
var _mouse_sensitivity: float = 0.003
var _invert_y: bool = false
var _camera_shake_enabled: bool = true
var _day_night_enabled: bool = true
var _fullscreen_enabled: bool = false
var _options_return_menu: String = "main"

var _master_slider: HSlider
var _sfx_slider: HSlider
var _ambience_slider: HSlider
var _mouse_slider: HSlider
var _invert_y_check: CheckBox
var _camera_shake_check: CheckBox
var _day_night_check: CheckBox
var _fullscreen_check: CheckBox


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_ensure_audio_bus(SFX_BUS)
	_ensure_audio_bus(AMBIENCE_BUS)
	_player = get_node_or_null(player_path)
	_camera = get_node_or_null(camera_path)
	_ambience = get_node_or_null(ambience_path)
	_build_ui()
	_load_settings()
	_apply_settings()
	_show_main_menu()


func _unhandled_input(event: InputEvent) -> void:
	var key_event := event as InputEventKey

	if key_event == null or not key_event.pressed or key_event.echo:
		return

	if key_event.keycode == KEY_ESCAPE:
		_handle_escape()
		get_viewport().set_input_as_handled()
	elif key_event.keycode == KEY_H:
		_toggle_help_overlay()
		get_viewport().set_input_as_handled()
	elif key_event.keycode == KEY_T:
		reset_all_props()
		get_viewport().set_input_as_handled()


func _build_ui() -> void:
	_root = Control.new()
	_root.set_anchors_preset(Control.PRESET_FULL_RECT)
	_root.process_mode = Node.PROCESS_MODE_ALWAYS
	# The root stays visible during gameplay, so it must not eat mouse motion.
	# Visible menu panels still receive clicks through their own Controls.
	_root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_root)

	_main_menu = _build_menu_panel("Flipflop Island")
	_add_button(_main_menu, "Play", _on_play_pressed)
	_add_button(_main_menu, "Options", _on_main_options_pressed)
	_add_button(_main_menu, "Quit", _on_quit_pressed)
	_root.add_child(_main_menu)

	_pause_menu = _build_menu_panel("Paused")
	_add_button(_pause_menu, "Resume", _on_resume_pressed)
	_add_button(_pause_menu, "Reset Flipflop", reset_flipflop)
	_add_button(_pause_menu, "Reset Props", reset_all_props)
	_add_button(_pause_menu, "Options", _on_pause_options_pressed)
	_add_button(_pause_menu, "Quit to Desktop", _on_quit_pressed)
	_root.add_child(_pause_menu)

	_options_menu = _build_menu_panel("Options")
	_master_slider = _add_slider(_options_menu, "Master Volume", 0.0, 1.0, 0.01, _on_master_volume_changed)
	_sfx_slider = _add_slider(_options_menu, "SFX Volume", 0.0, 1.0, 0.01, _on_sfx_volume_changed)
	_ambience_slider = _add_slider(_options_menu, "Music/Ambience Volume", 0.0, 1.0, 0.01, _on_ambience_volume_changed)
	_mouse_slider = _add_slider(_options_menu, "Mouse Sensitivity", 0.001, 0.01, 0.0001, _on_mouse_sensitivity_changed)
	_invert_y_check = _add_check_box(_options_menu, "Invert Y", _on_invert_y_toggled)
	_camera_shake_check = _add_check_box(_options_menu, "Camera Shake", _on_camera_shake_toggled)
	_day_night_check = _add_check_box(_options_menu, "Day/Night Cycle", _on_day_night_toggled)
	_fullscreen_check = _add_check_box(_options_menu, "Fullscreen", _on_fullscreen_toggled)
	_add_button(_options_menu, "Back", _on_options_back_pressed)
	_root.add_child(_options_menu)

	_help_overlay = _build_help_overlay()
	_root.add_child(_help_overlay)

	_main_menu.visible = false
	_pause_menu.visible = false
	_options_menu.visible = false
	_help_overlay.visible = false


func _build_menu_panel(title: String) -> Control:
	var overlay := Control.new()
	overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	overlay.process_mode = Node.PROCESS_MODE_ALWAYS
	overlay.mouse_filter = Control.MOUSE_FILTER_STOP

	var shade := ColorRect.new()
	shade.set_anchors_preset(Control.PRESET_FULL_RECT)
	shade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	shade.color = Color(0.0, 0.0, 0.0, 0.58)
	overlay.add_child(shade)

	var panel := PanelContainer.new()
	panel.anchor_left = 0.5
	panel.anchor_right = 0.5
	panel.anchor_top = 0.5
	panel.anchor_bottom = 0.5
	panel.offset_left = -180.0
	panel.offset_right = 180.0
	panel.offset_top = -260.0
	panel.offset_bottom = 260.0
	overlay.add_child(panel)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 18)
	margin.add_theme_constant_override("margin_right", 18)
	margin.add_theme_constant_override("margin_top", 18)
	margin.add_theme_constant_override("margin_bottom", 18)
	panel.add_child(margin)

	var list := VBoxContainer.new()
	list.name = "List"
	list.add_theme_constant_override("separation", 10)
	margin.add_child(list)

	var title_label := Label.new()
	title_label.text = title
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_label.add_theme_font_size_override("font_size", 26)
	list.add_child(title_label)

	return overlay


func _build_help_overlay() -> Control:
	var overlay := Control.new()
	overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	overlay.process_mode = Node.PROCESS_MODE_ALWAYS
	overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	overlay.add_to_group("debug_ui")

	var label := Label.new()
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	label.position = Vector2(24, 24)
	label.size = Vector2(440, 330)
	label.text = "\n".join([
		"Controls",
		"",
		"WASD / Arrows: move",
		"Left click: slap / lunge",
		"Shift: boost",
		"Mouse: rotate camera",
		"Scroll: zoom",
		"Space: hop / flap",
		"Q / E: twist",
		"R: reset flipflop",
		"T: reset physics props",
		"Escape: pause",
		"F1: debug panel",
		"F2: movement preset",
		"1: deserted island scenery",
		"2: resort pool scenery",
		"3: boardwalk scenery",
		"4: cruise ship deck scenery",
		"5: locker room scenery",
		"H: toggle this help",
		"P: photo mode",
		"C: flipflop color",
	])
	label.add_theme_color_override("font_color", Color(0.9, 1.0, 0.92))
	label.add_theme_color_override("font_shadow_color", Color(0.0, 0.0, 0.0))
	label.add_theme_constant_override("shadow_offset_x", 2)
	label.add_theme_constant_override("shadow_offset_y", 2)
	overlay.add_child(label)
	return overlay


func _get_menu_list(menu: Control) -> VBoxContainer:
	return menu.find_child("List", true, false) as VBoxContainer


func _add_button(menu: Control, text: String, callback: Callable) -> void:
	var button := Button.new()
	button.text = text
	button.pressed.connect(callback)
	_get_menu_list(menu).add_child(button)


func _add_slider(
	menu: Control,
	label_text: String,
	min_value: float,
	max_value: float,
	step: float,
	callback: Callable
) -> HSlider:
	var label := Label.new()
	label.text = label_text
	_get_menu_list(menu).add_child(label)

	var slider := HSlider.new()
	slider.min_value = min_value
	slider.max_value = max_value
	slider.step = step
	slider.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	slider.value_changed.connect(callback)
	_get_menu_list(menu).add_child(slider)
	return slider


func _add_check_box(menu: Control, text: String, callback: Callable) -> CheckBox:
	var check_box := CheckBox.new()
	check_box.text = text
	check_box.toggled.connect(callback)
	_get_menu_list(menu).add_child(check_box)
	return check_box


func _show_main_menu() -> void:
	get_tree().paused = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	_main_menu.visible = true
	_pause_menu.visible = false
	_options_menu.visible = false


func _show_pause_menu() -> void:
	get_tree().paused = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	_main_menu.visible = false
	_pause_menu.visible = true
	_options_menu.visible = false


func _resume_game() -> void:
	get_tree().paused = false
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	_main_menu.visible = false
	_pause_menu.visible = false
	_options_menu.visible = false


func _show_options(return_menu: String) -> void:
	_options_return_menu = return_menu
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	_main_menu.visible = false
	_pause_menu.visible = false
	_options_menu.visible = true
	_sync_option_controls()


func _handle_escape() -> void:
	if _options_menu.visible:
		_on_options_back_pressed()
	elif _main_menu.visible:
		return
	elif _pause_menu.visible:
		_resume_game()
	else:
		_show_pause_menu()


func _toggle_help_overlay() -> void:
	_help_overlay.visible = not _help_overlay.visible


func _on_play_pressed() -> void:
	_resume_game()


func _on_resume_pressed() -> void:
	_resume_game()


func _on_main_options_pressed() -> void:
	_show_options("main")


func _on_pause_options_pressed() -> void:
	_show_options("pause")


func _on_options_back_pressed() -> void:
	_save_settings()

	if _options_return_menu == "pause":
		_show_pause_menu()
	else:
		_show_main_menu()


func _on_quit_pressed() -> void:
	_save_settings()
	get_tree().quit()


func reset_flipflop() -> void:
	var scenery_manager: Node = get_tree().get_first_node_in_group("scenery_manager")
	if scenery_manager != null and scenery_manager.has_method("reset_player_to_current_spawn"):
		scenery_manager.call("reset_player_to_current_spawn")
		return

	if _player != null and _player.has_method("reset_flipflop"):
		_player.call("reset_flipflop")


func reset_all_props() -> void:
	var scenery_manager: Node = get_tree().get_first_node_in_group("scenery_manager")
	if scenery_manager != null and scenery_manager.has_method("reset_current_scenery_props"):
		scenery_manager.call("reset_current_scenery_props")
		return

	for prop in get_tree().get_nodes_in_group("resettable_prop"):
		if prop.has_method("reset_prop"):
			prop.call("reset_prop")


func _load_settings() -> void:
	var config := ConfigFile.new()
	var error: int = config.load(SETTINGS_PATH)

	if error != OK:
		return

	_master_volume = float(config.get_value("audio", "master_volume", _master_volume))
	_sfx_volume = float(config.get_value("audio", "sfx_volume", _sfx_volume))
	_ambience_volume = float(config.get_value("audio", "ambience_volume", _ambience_volume))
	_mouse_sensitivity = float(config.get_value("camera", "mouse_sensitivity", _mouse_sensitivity))
	_invert_y = bool(config.get_value("camera", "invert_y", _invert_y))
	_camera_shake_enabled = bool(config.get_value("camera", "camera_shake_enabled", _camera_shake_enabled))
	_day_night_enabled = bool(config.get_value("ambience", "day_night_enabled", _day_night_enabled))
	_fullscreen_enabled = bool(config.get_value("display", "fullscreen", _fullscreen_enabled))


func _save_settings() -> void:
	var config := ConfigFile.new()
	config.set_value("audio", "master_volume", _master_volume)
	config.set_value("audio", "sfx_volume", _sfx_volume)
	config.set_value("audio", "ambience_volume", _ambience_volume)
	config.set_value("camera", "mouse_sensitivity", _mouse_sensitivity)
	config.set_value("camera", "invert_y", _invert_y)
	config.set_value("camera", "camera_shake_enabled", _camera_shake_enabled)
	config.set_value("ambience", "day_night_enabled", _day_night_enabled)
	config.set_value("display", "fullscreen", _fullscreen_enabled)
	config.save(SETTINGS_PATH)


func _apply_settings() -> void:
	_set_bus_volume("Master", _master_volume)
	_set_bus_volume(SFX_BUS, _sfx_volume)
	_set_bus_volume(AMBIENCE_BUS, _ambience_volume)
	_apply_camera_settings()
	_apply_day_night_setting()
	_apply_fullscreen_setting()
	_sync_option_controls()


func _sync_option_controls() -> void:
	if _master_slider == null:
		return

	_master_slider.set_value_no_signal(_master_volume)
	_sfx_slider.set_value_no_signal(_sfx_volume)
	_ambience_slider.set_value_no_signal(_ambience_volume)
	_mouse_slider.set_value_no_signal(_mouse_sensitivity)
	_invert_y_check.set_pressed_no_signal(_invert_y)
	_camera_shake_check.set_pressed_no_signal(_camera_shake_enabled)
	_day_night_check.set_pressed_no_signal(_day_night_enabled)
	_fullscreen_check.set_pressed_no_signal(_fullscreen_enabled)


func _on_master_volume_changed(value: float) -> void:
	_master_volume = value
	_set_bus_volume("Master", _master_volume)
	_save_settings()


func _on_sfx_volume_changed(value: float) -> void:
	_sfx_volume = value
	_set_bus_volume(SFX_BUS, _sfx_volume)
	_save_settings()


func _on_ambience_volume_changed(value: float) -> void:
	_ambience_volume = value
	_set_bus_volume(AMBIENCE_BUS, _ambience_volume)
	_save_settings()


func _on_mouse_sensitivity_changed(value: float) -> void:
	_mouse_sensitivity = value
	_apply_camera_settings()
	_save_settings()


func _on_invert_y_toggled(enabled: bool) -> void:
	_invert_y = enabled
	_apply_camera_settings()
	_save_settings()


func _on_camera_shake_toggled(enabled: bool) -> void:
	_camera_shake_enabled = enabled
	_apply_camera_settings()
	_save_settings()


func _on_day_night_toggled(enabled: bool) -> void:
	_day_night_enabled = enabled
	_apply_day_night_setting()
	_save_settings()


func _on_fullscreen_toggled(enabled: bool) -> void:
	_fullscreen_enabled = enabled
	_apply_fullscreen_setting()
	_save_settings()


func _apply_camera_settings() -> void:
	if _camera == null:
		return

	_camera.set("mouse_sensitivity", _mouse_sensitivity)
	_camera.set("invert_y", _invert_y)

	if _camera.has_method("set_camera_shake_enabled"):
		_camera.call("set_camera_shake_enabled", _camera_shake_enabled)


func _apply_day_night_setting() -> void:
	if _ambience != null and _ambience.has_method("set_day_night_cycle_enabled"):
		_ambience.call("set_day_night_cycle_enabled", _day_night_enabled)


func _apply_fullscreen_setting() -> void:
	var mode := DisplayServer.WINDOW_MODE_FULLSCREEN if _fullscreen_enabled else DisplayServer.WINDOW_MODE_WINDOWED
	DisplayServer.window_set_mode(mode)


func _set_bus_volume(bus_name: String, volume: float) -> void:
	_ensure_audio_bus(bus_name)

	var bus_index := AudioServer.get_bus_index(bus_name)
	if bus_index == -1:
		return

	var clamped_volume := clampf(volume, 0.0, 1.0)
	if clamped_volume <= 0.001:
		AudioServer.set_bus_volume_db(bus_index, -80.0)
	else:
		AudioServer.set_bus_volume_db(bus_index, linear_to_db(clamped_volume))


func _ensure_audio_bus(bus_name: String) -> void:
	if AudioServer.get_bus_index(bus_name) != -1:
		return

	AudioServer.add_bus()
	AudioServer.set_bus_name(AudioServer.get_bus_count() - 1, bus_name)
