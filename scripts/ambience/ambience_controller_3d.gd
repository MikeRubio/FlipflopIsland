extends Node

# Calm island-wide ambience controller.
# This owns the optional day/night cycle and safe audio placeholders. It does
# not add goals or gameplay rules; it only changes mood.

@export var day_night_cycle_enabled: bool = true
@export var ambience_zone: String = "open island"

# How much of a full day passes per second. Lower values are slower.
# Example: 0.01 means a full loop takes about 100 seconds.
@export var cycle_speed: float = 0.006

# 0.0 = midnight, 0.25 = morning, 0.5 = noon, 0.75 = evening.
@export_range(0.0, 1.0, 0.001) var time_of_day: float = 0.42

@export var directional_light_path: NodePath
@export var world_environment_path: NodePath

@export_group("Audio Placeholders")
@export var ocean_loop_path: NodePath
@export var wind_loop_path: NodePath
@export var slap_sound_path: NodePath
@export var coconut_bump_path: NodePath
@export var shell_scatter_path: NodePath
@export var crab_skitter_path: NodePath
@export var pool_splash_path: NodePath
@export var resort_loop_path: NodePath
@export var seagull_call_path: NodePath
@export var auto_start_loops: bool = true

var _light: DirectionalLight3D
var _world_environment: WorldEnvironment
var _environment: Environment
var _sky_material: ProceduralSkyMaterial
var _ocean_loop: AudioStreamPlayer
var _wind_loop: AudioStreamPlayer
var _slap_sound: AudioStreamPlayer
var _coconut_bump: AudioStreamPlayer
var _shell_scatter: AudioStreamPlayer
var _crab_skitter: AudioStreamPlayer
var _pool_splash: AudioStreamPlayer
var _resort_loop: AudioStreamPlayer
var _seagull_call: AudioStreamPlayer


func _ready() -> void:
	add_to_group("ambience_debug")
	add_to_group("ambience_audio")
	_ensure_audio_bus("SFX")
	_ensure_audio_bus("Ambience")
	_light = get_node_or_null(directional_light_path) as DirectionalLight3D
	_world_environment = get_node_or_null(world_environment_path) as WorldEnvironment
	_ocean_loop = get_node_or_null(ocean_loop_path) as AudioStreamPlayer
	_wind_loop = get_node_or_null(wind_loop_path) as AudioStreamPlayer
	_slap_sound = get_node_or_null(slap_sound_path) as AudioStreamPlayer
	_coconut_bump = get_node_or_null(coconut_bump_path) as AudioStreamPlayer
	_shell_scatter = get_node_or_null(shell_scatter_path) as AudioStreamPlayer
	_crab_skitter = get_node_or_null(crab_skitter_path) as AudioStreamPlayer
	_pool_splash = get_node_or_null(pool_splash_path) as AudioStreamPlayer
	_resort_loop = get_node_or_null(resort_loop_path) as AudioStreamPlayer
	_seagull_call = get_node_or_null(seagull_call_path) as AudioStreamPlayer
	_assign_audio_buses()

	if _world_environment != null:
		_environment = _world_environment.environment
		if _environment != null and _environment.sky != null:
			_sky_material = _environment.sky.sky_material as ProceduralSkyMaterial

	if auto_start_loops:
		play_ocean_loop()
		play_wind_loop()
		play_resort_loop()

	_apply_lighting()


func _process(delta: float) -> void:
	if day_night_cycle_enabled:
		time_of_day = fposmod(time_of_day + delta * cycle_speed, 1.0)

	_apply_lighting()


func _apply_lighting() -> void:
	var sun_angle := time_of_day * TAU
	var daylight := clampf(sin(sun_angle - PI * 0.5) * 0.5 + 0.5, 0.0, 1.0)
	var sunrise_amount := maxf(0.0, 1.0 - absf(time_of_day - 0.25) / 0.12)
	var sunset_amount := maxf(0.0, 1.0 - absf(time_of_day - 0.75) / 0.12)
	var warm_edge := clampf(maxf(sunrise_amount, sunset_amount), 0.0, 1.0)

	if _light != null:
		_light.rotation_degrees = Vector3(
			lerpf(-18.0, -62.0, daylight),
			lerpf(-35.0, 25.0, time_of_day),
			0.0
		)
		_light.light_energy = lerpf(0.35, 2.1, daylight)
		_light.light_color = Color(1.0, lerpf(0.72, 0.96, daylight), lerpf(0.55, 0.88, daylight))

	if _environment != null:
		_environment.ambient_light_energy = lerpf(0.28, 0.78, daylight)

	if _sky_material != null:
		var night_top := Color(0.03, 0.05, 0.13)
		var day_top := Color(0.23, 0.48, 0.78)
		var sunset_top := Color(0.44, 0.2, 0.25)
		var top_color := night_top.lerp(day_top, daylight).lerp(sunset_top, warm_edge * 0.25)
		var horizon_color := Color(0.07, 0.12, 0.18).lerp(Color(0.78, 0.9, 0.95), daylight)
		_sky_material.sky_top_color = top_color
		_sky_material.sky_horizon_color = horizon_color


func play_ocean_loop() -> void:
	_play_if_stream_exists(_ocean_loop)


func play_wind_loop() -> void:
	_play_if_stream_exists(_wind_loop)


func play_slap_sound() -> void:
	_play_if_stream_exists(_slap_sound)


func play_coconut_bump() -> void:
	_play_if_stream_exists(_coconut_bump)


func play_shell_scatter() -> void:
	_play_if_stream_exists(_shell_scatter)


func play_crab_skitter() -> void:
	_play_if_stream_exists(_crab_skitter)


func play_pool_splash() -> void:
	_play_if_stream_exists(_pool_splash)


func play_resort_loop() -> void:
	_play_if_stream_exists(_resort_loop)


func play_seagull_call() -> void:
	_play_if_stream_exists(_seagull_call)


func set_day_night_cycle_enabled(enabled: bool) -> void:
	day_night_cycle_enabled = enabled


func _ensure_audio_bus(bus_name: String) -> void:
	if AudioServer.get_bus_index(bus_name) != -1:
		return

	AudioServer.add_bus()
	AudioServer.set_bus_name(AudioServer.get_bus_count() - 1, bus_name)


func _assign_audio_buses() -> void:
	if _ocean_loop != null:
		_ocean_loop.bus = "Ambience"
	if _wind_loop != null:
		_wind_loop.bus = "Ambience"
	if _slap_sound != null:
		_slap_sound.bus = "SFX"
	if _coconut_bump != null:
		_coconut_bump.bus = "SFX"
	if _shell_scatter != null:
		_shell_scatter.bus = "SFX"
	if _crab_skitter != null:
		_crab_skitter.bus = "SFX"
	if _pool_splash != null:
		_pool_splash.bus = "SFX"
	if _resort_loop != null:
		_resort_loop.bus = "Ambience"
	if _seagull_call != null:
		_seagull_call.bus = "Ambience"


func _play_if_stream_exists(player: AudioStreamPlayer) -> void:
	if player == null or player.stream == null:
		return

	if not player.playing:
		player.play()


func get_ambience_debug_state() -> Dictionary:
	return {
		"time_of_day": time_of_day,
		"day_night_cycle_enabled": day_night_cycle_enabled,
		"cycle_speed": cycle_speed,
		"ambience_zone": ambience_zone,
	}
