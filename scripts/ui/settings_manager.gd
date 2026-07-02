extends Node

# Runtime-only settings for Flipflop Island.
# Menus update this singleton, active gameplay systems register themselves so
# settings apply immediately, and values persist in user://settings.cfg.

signal settings_changed

const SFX_BUS := "SFX"
const AMBIENCE_BUS := "Ambience"
const SETTINGS_PATH := "user://settings.cfg"

const DEFAULT_MASTER_VOLUME := 0.85
const DEFAULT_SFX_VOLUME := 0.85
const DEFAULT_AMBIENCE_VOLUME := 0.75
const DEFAULT_MOUSE_SENSITIVITY := 0.003
const DEFAULT_INVERT_Y := false
const DEFAULT_CAMERA_SHAKE_ENABLED := true
const DEFAULT_DAY_NIGHT_ENABLED := true
const DEFAULT_FULLSCREEN_ENABLED := false
const DEFAULT_MOVEMENT_PRESET := "Playable Physics"
const DEFAULT_LAST_SCENERY_ID := "deserted_island"

var master_volume: float = DEFAULT_MASTER_VOLUME
var sfx_volume: float = DEFAULT_SFX_VOLUME
var ambience_volume: float = DEFAULT_AMBIENCE_VOLUME
var mouse_sensitivity: float = DEFAULT_MOUSE_SENSITIVITY
var invert_y: bool = DEFAULT_INVERT_Y
var camera_shake_enabled: bool = DEFAULT_CAMERA_SHAKE_ENABLED
var day_night_enabled: bool = DEFAULT_DAY_NIGHT_ENABLED
var fullscreen_enabled: bool = DEFAULT_FULLSCREEN_ENABLED
var movement_preset_name: String = DEFAULT_MOVEMENT_PRESET
var last_scenery_id: String = DEFAULT_LAST_SCENERY_ID

var _camera: Node
var _ambience: Node
var _player: Node
var _is_loading: bool = false


func _ready() -> void:
	ensure_audio_buses()
	load_settings()
	apply_all()


func register_camera(camera: Node) -> void:
	_camera = camera
	_apply_camera_settings()


func register_ambience(ambience: Node) -> void:
	_ambience = ambience
	_apply_ambience_settings()


func register_player(player: Node) -> void:
	_player = player
	_apply_player_settings()


func clear_camera(camera: Node) -> void:
	if _camera == camera:
		_camera = null


func clear_ambience(ambience: Node) -> void:
	if _ambience == ambience:
		_ambience = null


func clear_player(player: Node) -> void:
	if _player == player:
		_player = null


func set_master_volume(value: float) -> void:
	master_volume = clampf(value, 0.0, 1.0)
	_apply_audio_settings()
	_save_if_ready()
	settings_changed.emit()


func set_sfx_volume(value: float) -> void:
	sfx_volume = clampf(value, 0.0, 1.0)
	_apply_audio_settings()
	_save_if_ready()
	settings_changed.emit()


func set_ambience_volume(value: float) -> void:
	ambience_volume = clampf(value, 0.0, 1.0)
	_apply_audio_settings()
	_save_if_ready()
	settings_changed.emit()


func set_mouse_sensitivity(value: float) -> void:
	mouse_sensitivity = clampf(value, 0.001, 0.02)
	_apply_camera_settings()
	_save_if_ready()
	settings_changed.emit()


func set_invert_y(enabled: bool) -> void:
	invert_y = enabled
	_apply_camera_settings()
	_save_if_ready()
	settings_changed.emit()


func set_camera_shake_enabled(enabled: bool) -> void:
	camera_shake_enabled = enabled
	_apply_camera_settings()
	_save_if_ready()
	settings_changed.emit()


func set_day_night_enabled(enabled: bool) -> void:
	day_night_enabled = enabled
	_apply_ambience_settings()
	_save_if_ready()
	settings_changed.emit()


func set_fullscreen_enabled(enabled: bool) -> void:
	fullscreen_enabled = enabled
	_apply_fullscreen_setting()
	_save_if_ready()
	settings_changed.emit()


func set_movement_preset_name(preset_name: String) -> void:
	if preset_name.is_empty():
		return

	movement_preset_name = preset_name
	_apply_player_settings()
	_save_if_ready()
	settings_changed.emit()


func set_last_scenery_id(scenery_id: String) -> void:
	if scenery_id.is_empty():
		return

	last_scenery_id = scenery_id
	_save_if_ready()
	settings_changed.emit()


func apply_all() -> void:
	_apply_audio_settings()
	_apply_camera_settings()
	_apply_ambience_settings()
	_apply_fullscreen_setting()
	_apply_player_settings()


func load_settings() -> void:
	_is_loading = true

	var config: ConfigFile = ConfigFile.new()
	var error: int = config.load(SETTINGS_PATH)

	if error != OK:
		if error != ERR_FILE_NOT_FOUND:
			push_warning("Could not load settings from %s. Using defaults. Error: %s" % [SETTINGS_PATH, error])
		_reset_to_defaults_without_save()
		_is_loading = false
		return

	master_volume = clampf(float(config.get_value("audio", "master_volume", DEFAULT_MASTER_VOLUME)), 0.0, 1.0)
	sfx_volume = clampf(float(config.get_value("audio", "sfx_volume", DEFAULT_SFX_VOLUME)), 0.0, 1.0)
	ambience_volume = clampf(float(config.get_value("audio", "ambience_volume", DEFAULT_AMBIENCE_VOLUME)), 0.0, 1.0)
	mouse_sensitivity = clampf(float(config.get_value("camera", "mouse_sensitivity", DEFAULT_MOUSE_SENSITIVITY)), 0.001, 0.02)
	invert_y = bool(config.get_value("camera", "invert_y", DEFAULT_INVERT_Y))
	camera_shake_enabled = bool(config.get_value("camera", "camera_shake_enabled", DEFAULT_CAMERA_SHAKE_ENABLED))
	day_night_enabled = bool(config.get_value("ambience", "day_night_enabled", DEFAULT_DAY_NIGHT_ENABLED))
	fullscreen_enabled = bool(config.get_value("display", "fullscreen_enabled", DEFAULT_FULLSCREEN_ENABLED))
	movement_preset_name = String(config.get_value("gameplay", "movement_preset_name", DEFAULT_MOVEMENT_PRESET))
	last_scenery_id = String(config.get_value("gameplay", "last_scenery_id", DEFAULT_LAST_SCENERY_ID))

	if movement_preset_name.is_empty():
		movement_preset_name = DEFAULT_MOVEMENT_PRESET
	if last_scenery_id.is_empty():
		last_scenery_id = DEFAULT_LAST_SCENERY_ID

	_is_loading = false


func save_settings() -> void:
	var config: ConfigFile = ConfigFile.new()
	config.set_value("audio", "master_volume", master_volume)
	config.set_value("audio", "sfx_volume", sfx_volume)
	config.set_value("audio", "ambience_volume", ambience_volume)
	config.set_value("camera", "mouse_sensitivity", mouse_sensitivity)
	config.set_value("camera", "invert_y", invert_y)
	config.set_value("camera", "camera_shake_enabled", camera_shake_enabled)
	config.set_value("ambience", "day_night_enabled", day_night_enabled)
	config.set_value("display", "fullscreen_enabled", fullscreen_enabled)
	config.set_value("gameplay", "movement_preset_name", movement_preset_name)
	config.set_value("gameplay", "last_scenery_id", last_scenery_id)

	var error: int = config.save(SETTINGS_PATH)
	if error != OK:
		push_warning("Could not save settings to %s. Error: %s" % [SETTINGS_PATH, error])


func reset_to_defaults() -> void:
	_reset_to_defaults_without_save()
	apply_all()
	save_settings()
	settings_changed.emit()


func ensure_audio_buses() -> void:
	_ensure_audio_bus(SFX_BUS)
	_ensure_audio_bus(AMBIENCE_BUS)


func _apply_audio_settings() -> void:
	ensure_audio_buses()
	_set_bus_volume("Master", master_volume)
	_set_bus_volume(SFX_BUS, sfx_volume)
	_set_bus_volume(AMBIENCE_BUS, ambience_volume)


func _apply_camera_settings() -> void:
	if _camera == null or not is_instance_valid(_camera):
		_camera = null
		return

	_camera.set("mouse_sensitivity", mouse_sensitivity)
	_camera.set("invert_y", invert_y)

	if _camera.has_method("set_camera_shake_enabled"):
		_camera.call("set_camera_shake_enabled", camera_shake_enabled)
	else:
		push_warning("Registered camera does not expose set_camera_shake_enabled().")


func _apply_ambience_settings() -> void:
	if _ambience == null or not is_instance_valid(_ambience):
		_ambience = null
		return

	if _ambience.has_method("set_day_night_cycle_enabled"):
		_ambience.call("set_day_night_cycle_enabled", day_night_enabled)
	else:
		push_warning("Registered ambience node does not expose set_day_night_cycle_enabled().")


func _apply_player_settings() -> void:
	if _player == null or not is_instance_valid(_player):
		_player = null
		return

	if _player.has_method("apply_movement_preset"):
		_player.call("apply_movement_preset", movement_preset_name)
	else:
		push_warning("Registered player does not expose apply_movement_preset().")


func _apply_fullscreen_setting() -> void:
	var mode: int = (
		DisplayServer.WINDOW_MODE_FULLSCREEN
		if fullscreen_enabled
		else DisplayServer.WINDOW_MODE_WINDOWED
	)
	DisplayServer.window_set_mode(mode)


func _set_bus_volume(bus_name: String, volume: float) -> void:
	_ensure_audio_bus(bus_name)

	var bus_index: int = AudioServer.get_bus_index(bus_name)
	if bus_index == -1:
		push_warning("Audio bus '%s' is missing and could not be created." % bus_name)
		return

	var clamped_volume: float = clampf(volume, 0.0, 1.0)
	if clamped_volume <= 0.001:
		AudioServer.set_bus_volume_db(bus_index, -80.0)
	else:
		AudioServer.set_bus_volume_db(bus_index, linear_to_db(clamped_volume))


func _ensure_audio_bus(bus_name: String) -> void:
	if AudioServer.get_bus_index(bus_name) != -1:
		return

	AudioServer.add_bus()
	AudioServer.set_bus_name(AudioServer.get_bus_count() - 1, bus_name)


func _save_if_ready() -> void:
	if _is_loading:
		return

	save_settings()


func _reset_to_defaults_without_save() -> void:
	master_volume = DEFAULT_MASTER_VOLUME
	sfx_volume = DEFAULT_SFX_VOLUME
	ambience_volume = DEFAULT_AMBIENCE_VOLUME
	mouse_sensitivity = DEFAULT_MOUSE_SENSITIVITY
	invert_y = DEFAULT_INVERT_Y
	camera_shake_enabled = DEFAULT_CAMERA_SHAKE_ENABLED
	day_night_enabled = DEFAULT_DAY_NIGHT_ENABLED
	fullscreen_enabled = DEFAULT_FULLSCREEN_ENABLED
	movement_preset_name = DEFAULT_MOVEMENT_PRESET
	last_scenery_id = DEFAULT_LAST_SCENERY_ID
