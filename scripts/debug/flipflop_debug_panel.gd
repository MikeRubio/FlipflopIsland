extends CanvasLayer

# Temporary tuning panel for the 3D flipflop controller.
# This is intentionally plain: it is a quick in-game readout for tuning physics,
# not a final game menu.

@export var player_path: NodePath
@export var panel_visible_by_default: bool = false

var _player: Node
var _label: Label


func _ready() -> void:
	add_to_group("debug_ui")
	_player = get_node_or_null(player_path)
	_build_label()
	visible = panel_visible_by_default


func _unhandled_input(event: InputEvent) -> void:
	var key_event := event as InputEventKey

	if key_event == null or not key_event.pressed or key_event.echo:
		return

	if key_event.keycode == KEY_F1:
		if _is_photo_mode_enabled():
			visible = false
			return

		visible = not visible
	elif key_event.keycode == KEY_F2:
		_cycle_player_preset()


func _process(_delta: float) -> void:
	if not visible:
		return

	if _player == null or not _player.has_method("get_movement_debug_state"):
		_label.text = "Flipflop Debug\nPlayer not found."
		return

	var state: Dictionary = _player.call("get_movement_debug_state")
	_label.text = _format_state(
		state,
		_get_current_scenery_name(),
		_get_ambience_state(),
		_get_existence_state(),
		_get_ship_motion_state()
	)


func _build_label() -> void:
	_label = Label.new()
	_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_label.position = Vector2(16, 16)
	_label.size = Vector2(620, 760)
	_label.add_theme_color_override("font_color", Color(0.9, 1.0, 0.92))
	_label.add_theme_color_override("font_shadow_color", Color(0.0, 0.0, 0.0))
	_label.add_theme_constant_override("shadow_offset_x", 2)
	_label.add_theme_constant_override("shadow_offset_y", 2)
	add_child(_label)


func _cycle_player_preset() -> void:
	if _player == null or not _player.has_method("cycle_movement_preset"):
		return

	_player.call("cycle_movement_preset")


func _get_ambience_state() -> Dictionary:
	var ambience: Node = get_tree().get_first_node_in_group("ambience_debug")
	if ambience == null or not ambience.has_method("get_ambience_debug_state"):
		return {}

	var state: Variant = ambience.call("get_ambience_debug_state")
	if state is Dictionary:
		var typed_state: Dictionary = state
		return typed_state

	return {}


func _get_existence_state() -> Dictionary:
	var existence: Node = get_tree().get_first_node_in_group("existence_debug")
	if existence == null or not existence.has_method("get_existence_debug_state"):
		return {}

	var state: Variant = existence.call("get_existence_debug_state")
	if state is Dictionary:
		var typed_state: Dictionary = state
		return typed_state

	return {}


func _get_ship_motion_state() -> Dictionary:
	var ship_motion: Node = get_tree().get_first_node_in_group("ship_motion_debug")
	if ship_motion == null or not ship_motion.has_method("get_ship_motion_debug_state"):
		return {}

	var state: Variant = ship_motion.call("get_ship_motion_debug_state")
	if state is Dictionary:
		var typed_state: Dictionary = state
		return typed_state

	return {}


func _get_current_scenery_name() -> String:
	var scenery_manager: Node = get_tree().get_first_node_in_group("scenery_manager")
	if scenery_manager == null or not scenery_manager.has_method("get_current_scenery_name"):
		return "Unknown"

	return String(scenery_manager.call("get_current_scenery_name"))


func _is_photo_mode_enabled() -> bool:
	var photo_mode: Node = get_tree().get_first_node_in_group("photo_mode_controller")
	if photo_mode == null or not photo_mode.has_method("is_photo_mode_enabled"):
		return false

	return bool(photo_mode.call("is_photo_mode_enabled"))


func _format_state(
	state: Dictionary,
	scenery_name: String,
	ambience_state: Dictionary,
	existence_state: Dictionary,
	ship_motion_state: Dictionary
) -> String:
	var lines := [
		"Flipflop Movement Debug",
		"F1: Toggle panel",
		"F2: Cycle preset",
		"F3: Toggle flavor text",
		"P: Toggle photo mode",
		"C: Cycle flipflop color",
		"",
		"Scenery: %s" % scenery_name,
		"Preset: %s" % state.get("preset", "Unknown"),
		"Shift boost active: %s" % state.get("boost_active", false),
		"Current move multiplier: %.2f" % state.get("current_move_multiplier", 1.0),
		"Current max linear speed: %.2f" % state.get("current_max_linear_speed", 0.0),
		"Current max angular speed: %.2f" % state.get("current_max_angular_speed", 0.0),
		"Slap cooldown: %.2f" % state.get("slap_cooldown", 0.0),
		"Slap active: %s" % state.get("slap_active", false),
		"Shift slap active: %s" % state.get("shift_slap_active", false),
		"Current slap direction: %s" % state.get("current_slap_direction", Vector3.FORWARD),
		"Last slapped object: %s" % state.get("last_slapped_object_name", "none"),
		"Current slap strength: %.2f" % state.get("current_slap_strength", 0.0),
		"Flipflop color: %s" % state.get("flipflop_color", "unknown"),
		"Raw WASD input: %s" % state.get("raw_move_input", Vector2.ZERO),
		"Camera forward flat: %s" % state.get("camera_forward", Vector3.FORWARD),
		"Camera right flat: %s" % state.get("camera_right", Vector3.RIGHT),
		"Final movement direction: %s" % state.get("input_direction", Vector3.ZERO),
		"Face camera enabled: %s" % state.get("face_camera_enabled", false),
		"Target yaw: %.1f" % state.get("target_yaw", 0.0),
		"Current yaw: %.1f" % state.get("current_yaw", 0.0),
		"Yaw difference: %.1f" % state.get("yaw_difference", 0.0),
		"Yaw alignment active: %s" % state.get("yaw_alignment_active", false),
		"Yaw align strength: %.3f" % state.get("yaw_align_strength", 0.0),
		"Yaw align torque: %.3f" % state.get("yaw_align_torque_applied", 0.0),
		"Move force applied: %s" % state.get("move_force_applied", Vector3.ZERO),
		"Surface type: %s" % state.get("surface_type", "default"),
		"Surface: %s" % state.get("surface_name", "default"),
		"Surface move multiplier: %.2f" % state.get("surface_move_multiplier", 1.0),
		"Surface damping multiplier: %.2f" % state.get("surface_damping_multiplier", 1.0),
		"Surface jump multiplier: %.2f" % state.get("surface_jump_multiplier", 1.0),
		"Surface landing multiplier: %.2f" % state.get("surface_landing_impact_multiplier", 1.0),
		"In water: %s" % state.get("in_water", false),
		"Water timer: %.2f" % state.get("water_timer", 0.0),
		"Water reset timer: %.2f" % state.get("water_reset_timer", 0.0),
		"Water drag active: %s" % state.get("water_drag_active", false),
		"Water buoyancy active: %s" % state.get("water_buoyancy_active", false),
		"Water reset triggered: %s" % state.get("water_soft_reset_triggered", false),
		"Water surface Y: %.2f" % state.get("water_surface_y", 0.0),
		"Water safe exit: %s" % state.get("water_safe_exit_position", Vector3.ZERO),
		"Linear velocity: %s" % state.get("linear_velocity", Vector3.ZERO),
		"Angular velocity: %s" % state.get("angular_velocity", Vector3.ZERO),
		"Linear speed: %.2f" % state.get("linear_speed", 0.0),
		"Angular speed: %.2f" % state.get("angular_speed", 0.0),
		"Grounded: %s" % state.get("grounded", false),
		"Air flaps remaining: %s / %s" % [
			state.get("air_flaps_remaining", 0),
			state.get("max_air_flaps", 0),
		],
		"Flap cooldown: %.2f" % state.get("flap_cooldown", 0.0),
		"Vertical velocity: %.2f" % state.get("vertical_velocity", 0.0),
		"Max upward velocity: %.2f" % state.get("max_upward_velocity", 0.0),
		"Last jump type: %s" % state.get("last_jump_type", "none"),
		"Sleeping: %s" % state.get("sleeping", false),
		"Player Y: %.3f" % state.get("player_y", 0.0),
		"Safe ground Y: %.3f" % state.get("safe_ground_y", 0.0),
		"Recovered this frame: %s" % state.get("stuck_recovery_triggered", false),
		"Collision contacts: %s" % state.get("collision_contacts", 0),
		"Speed clamp active: %s" % state.get("speed_clamped", false),
		"",
		"move_force: %.3f" % state.get("move_force", 0.0),
		"move_impulse: %.3f" % state.get("move_impulse", 0.0),
		"ground_hop_impulse: %.3f" % state.get("ground_hop_impulse", 0.0),
		"jump_forward_assist: %.3f" % state.get("jump_forward_assist", 0.0),
		"max_air_flaps: %s" % state.get("max_air_flaps", 0),
		"air_flap_impulse: %.3f" % state.get("air_flap_impulse", 0.0),
		"air_flap_torque: %.3f" % state.get("air_flap_torque", 0.0),
		"flap_cooldown: %.2f" % state.get("flap_cooldown_time", 0.0),
		"max_upward_velocity: %.2f" % state.get("max_upward_velocity", 0.0),
		"torque_strength: %.3f" % state.get("torque_strength", 0.0),
		"movement_wobble_torque: %.3f" % state.get("movement_wobble_torque", 0.0),
		"boost_move_multiplier: %.2f" % state.get("boost_move_multiplier", 1.0),
		"boost_hop_assist_multiplier: %.2f" % state.get("boost_hop_assist_multiplier", 1.0),
		"boost_wobble_multiplier: %.2f" % state.get("boost_wobble_multiplier", 1.0),
		"boost_max_linear_speed: %.2f" % state.get("boost_max_linear_speed", 0.0),
		"boost_max_angular_speed: %.2f" % state.get("boost_max_angular_speed", 0.0),
		"boost_slap_multiplier: %.2f" % state.get("boost_slap_multiplier", 1.0),
		"boost_camera_bump_strength: %.2f" % state.get("boost_camera_bump_strength", 0.0),
		"slap_forward_impulse: %.2f" % state.get("slap_forward_impulse", 0.0),
		"slap_upward_impulse: %.2f" % state.get("slap_upward_impulse", 0.0),
		"slap_torque: %.3f" % state.get("slap_torque", 0.0),
		"slap_cooldown_time: %.2f" % state.get("slap_cooldown_time", 0.0),
		"slap_active_duration: %.2f" % state.get("slap_active_duration", 0.0),
		"slap_prop_force_multiplier: %.2f" % state.get("slap_prop_force_multiplier", 0.0),
		"shift_slap_multiplier: %.2f" % state.get("shift_slap_multiplier", 1.0),
		"slap_max_speed: %.2f" % state.get("slap_max_speed", 0.0),
		"slap_ground_clearance_boost: %.3f" % state.get(
			"slap_ground_clearance_boost",
			0.0
		),
		"linear_damping: %.2f" % state.get("linear_damping", 0.0),
		"angular_damping: %.2f" % state.get("angular_damping", 0.0),
		"max_linear_speed: %.2f" % state.get("max_linear_speed", 0.0),
		"max_angular_speed: %.2f" % state.get("max_angular_speed", 0.0),
		"yaw_align_damping: %.3f" % state.get("yaw_align_damping", 0.0),
		"max_yaw_angular_velocity: %.2f" % state.get("max_yaw_angular_velocity", 0.0),
		"face_camera_smoothing: %.2f" % state.get("face_camera_smoothing", 0.0),
		"preserve_pitch_roll: %s" % state.get("preserve_pitch_roll", true),
		"alignment_deadzone_degrees: %.1f" % state.get(
			"alignment_deadzone_degrees",
			0.0
		),
		"water_drag_multiplier: %.2f" % state.get("water_drag_multiplier", 0.0),
		"water_angular_drag_multiplier: %.2f" % state.get("water_angular_drag_multiplier", 0.0),
		"water_buoyancy_force: %.2f" % state.get("water_buoyancy_force", 0.0),
		"water_push_to_shore_force: %.2f" % state.get("water_push_to_shore_force", 0.0),
		"water_spin_damping: %.2f" % state.get("water_spin_damping", 0.0),
		"water_max_time_before_soft_reset: %.2f" % state.get(
			"water_max_time_before_soft_reset",
			0.0
		),
	]

	if not ambience_state.is_empty():
		lines.append("")
		lines.append("Ambience")
		lines.append("Time of day: %.2f" % ambience_state.get("time_of_day", 0.0))
		lines.append("Day/night enabled: %s" % ambience_state.get("day_night_cycle_enabled", false))
		lines.append("Cycle speed: %.3f" % ambience_state.get("cycle_speed", 0.0))
		lines.append("Zone: %s" % ambience_state.get("ambience_zone", "unknown"))

	if not ship_motion_state.is_empty():
		lines.append("")
		lines.append("Cruise Ship Motion")
		lines.append("Ship sway enabled: %s" % ship_motion_state.get("ship_sway_enabled", false))
		lines.append("Ship sway strength: %.3f" % ship_motion_state.get("ship_sway_strength", 0.0))
		lines.append("Ship sway speed: %.3f" % ship_motion_state.get("ship_sway_speed", 0.0))
		lines.append("Wind push enabled: %s" % ship_motion_state.get("wind_push_enabled", false))
		lines.append("Wind push strength: %.3f" % ship_motion_state.get("wind_push_strength", 0.0))
		lines.append("Wind direction: %s" % ship_motion_state.get("wind_direction", Vector3.RIGHT))
		lines.append("Sway force: %s" % ship_motion_state.get("sway_force", Vector3.ZERO))
		lines.append("Wind force: %s" % ship_motion_state.get("wind_force", Vector3.ZERO))
		lines.append("Bodies affected: %s" % ship_motion_state.get("affected_body_count", 0))

	if not existence_state.is_empty():
		lines.append("")
		lines.append("Existence")
		lines.append("Session time: %s" % _format_seconds(float(existence_state.get("existence_time", 0.0))))
		lines.append("Photo mode: %s" % existence_state.get("photo_mode_enabled", false))
		lines.append("Flavor text enabled: %s" % existence_state.get("flavor_messages_enabled", false))
		lines.append("Next message in: %.1fs" % existence_state.get("next_message_in", 0.0))

	return "\n".join(lines)


func _format_seconds(total_seconds: float) -> String:
	var seconds := int(total_seconds) % 60
	var minutes := int(total_seconds / 60.0) % 60
	var hours := int(total_seconds / 3600.0)

	return "%02d:%02d:%02d" % [hours, minutes, seconds]
