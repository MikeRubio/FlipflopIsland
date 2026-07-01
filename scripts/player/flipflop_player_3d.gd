extends RigidBody3D

# Physics controller for the lost flipflop.
# This is deliberately not a humanoid controller: WASD gives the RigidBody3D
# camera-relative central force for readable movement. Small optional torque adds
# wobble, but WASD should not roll the flipflop like a wheel.

# Main movement force applied while WASD is held.
# This is the primary control value for moving across the sand.
@export var move_force: float = 2.25

# Optional tiny extra shove applied every physics frame while input is held.
# This helps a small RigidBody3D overcome static friction without big launches.
@export var move_impulse: float = 0.0045

# Space hop/flap tuning. Ground hops are stronger. Air flaps are repeatable,
# Flappy Bird-style, but limited by max_air_flaps and max_upward_velocity.
@export var max_air_flaps: int = 4
@export var ground_hop_impulse: float = 0.56
@export var air_flap_impulse: float = 0.36
@export var flap_cooldown: float = 0.2
@export var max_upward_velocity: float = 4.3

# Small camera-relative shove added to a hop/flap when WASD is held.
@export var jump_forward_assist: float = 0.16

# Tiny random torque applied on air flaps for floppy personality.
@export var air_flap_torque: float = 0.045

# Shared torque strength for flopping, rolling, and twisting.
# Lower values make controls calmer. Higher values create more tumbling.
@export var torque_strength: float = 0.016

# Tiny yaw wobble added during WASD movement for physical flavor.
# This should stay low. It is not used to move the flipflop forward.
@export var movement_wobble_torque: float = 0.0035

# Shift boost makes the flipflop shove harder while still using central force.
# This should feel like the sandal is trying harder, not like a clean sprint.
@export var boost_enabled: bool = true
@export var boost_move_multiplier: float = 1.42
@export var boost_hop_assist_multiplier: float = 1.18
@export var boost_wobble_multiplier: float = 1.35
@export var boost_max_linear_speed: float = 4.9
@export var boost_max_angular_speed: float = 5.2
@export var boost_slap_multiplier: float = 1.18
@export var boost_camera_bump_strength: float = 0.1

# Left click slap/lunge. This is a quick forward sandal slap, not a jump and
# not a combat attack. Most of the impulse goes along camera-forward on X/Z.
@export var slap_forward_impulse: float = 0.72
@export var slap_upward_impulse: float = 0.022
@export var slap_torque: float = 0.028
@export var slap_cooldown: float = 0.56
@export var slap_active_duration: float = 0.22
@export var slap_prop_force_multiplier: float = 2.7
@export var shift_slap_multiplier: float = 1.35
@export var slap_max_speed: float = 5.0
@export var slap_ground_clearance_boost: float = 0.022
@export var slap_camera_bump: float = 0.065
@export var slap_particle_enabled: bool = true

# Air control is intentionally weaker so airborne movement feels clumsy.
@export var air_control_multiplier: float = 0.11

# Ground control is stronger because the flipflop can push against the sand.
@export var ground_control_multiplier: float = 1.0

# Damping values calm the physics down over time.
# Lower linear damping means more sliding. Higher angular damping means less
# endless spinning.
@export var linear_damping: float = 0.62
@export var angular_damping: float = 3.5

# Safety clamps. These keep tumbling funny without becoming impossible to test.
@export var max_linear_speed: float = 3.9
@export var max_angular_speed: float = 4.5

# Camera-facing alignment. This gently turns the RigidBody3D around world Y so
# the flipflop points where the camera points, while pitch/roll can still wobble.
@export_group("Face Camera Alignment")
@export var face_camera_enabled: bool = true
@export var yaw_align_strength: float = 0.16
@export var yaw_align_damping: float = 0.09
@export var max_yaw_angular_velocity: float = 2.3
@export var face_camera_smoothing: float = 8.0
@export var preserve_pitch_roll: bool = true
@export var alignment_deadzone_degrees: float = 3.0
@export_group("")

# Ground detection uses a world-down raycast, so it still works when the
# flipflop lands sideways or upside down.
@export var ground_check_distance: float = 0.44
@export var grounded_grace_time: float = 0.12
@export var hop_input_buffer_time: float = 0.14

# Holding Space while grounded gives a small recovery torque if the flipflop is
# upside down or badly tilted. It is not automatic, so funny physics remain.
@export var upside_down_help_strength: float = 0.5

# Hard landings call the placeholder feedback functions below.
@export var landing_slap_threshold: float = 3.0

# Reset tuning.
@export var reset_position: Vector3 = Vector3(0.0, 0.35, 0.0)
@export var reset_rotation_degrees: Vector3 = Vector3.ZERO
@export var fall_reset_height: float = -8.0

# The main sand surface is near Y=0. If the flipflop body gets below this by
# more than stuck_recovery_depth, gently place it back above the sand.
@export var safe_ground_y: float = 0.0
@export var safe_ground_clearance: float = 0.18
@export var stuck_recovery_depth: float = 0.08
@export var stuck_recovery_cooldown: float = 0.3
@export var recovery_velocity_scale: float = 0.25

# Water is handled as a soft Area3D state, not as a solid collision surface.
# These values keep the flipflop from jittering, spinning, or getting trapped
# when it touches ocean/pool water.
@export_group("Water Interaction")
@export var water_drag_multiplier: float = 2.4
@export var water_angular_drag_multiplier: float = 2.1
@export var water_buoyancy_force: float = 0.55
@export var water_push_to_shore_force: float = 0.24
@export var water_max_time_before_soft_reset: float = 3.5
@export var water_surface_y: float = 0.0
@export var water_safe_exit_position: Vector3 = Vector3(0.0, 0.35, 0.0)
@export_range(0.0, 1.0, 0.01) var water_spin_damping: float = 0.86
@export var splash_enabled: bool = true
@export var water_max_linear_speed: float = 2.2
@export var water_max_angular_speed: float = 2.4
@export var water_soft_reset_depth: float = 0.75
@export_group("")

# Temporary movement debug. Leave off during normal play.
@export var debug_movement: bool = false
@export var debug_print_interval: float = 0.35

@onready var _ground_ray: RayCast3D = $GroundRay
@onready var _sole_mesh: MeshInstance3D = $Sole

const MOVEMENT_PRESETS := {
	"Gentle": {
		"move_force": 1.65,
		"move_impulse": 0.0025,
		"ground_hop_impulse": 0.46,
		"jump_forward_assist": 0.12,
		"max_air_flaps": 3,
		"air_flap_impulse": 0.28,
		"air_flap_torque": 0.025,
		"flap_cooldown": 0.24,
		"max_upward_velocity": 3.4,
		"torque_strength": 0.01,
		"movement_wobble_torque": 0.0015,
		"boost_enabled": true,
		"boost_move_multiplier": 1.18,
		"boost_hop_assist_multiplier": 1.08,
		"boost_wobble_multiplier": 1.15,
		"boost_max_linear_speed": 3.5,
		"boost_max_angular_speed": 3.8,
		"boost_slap_multiplier": 1.05,
		"boost_camera_bump_strength": 0.06,
		"slap_forward_impulse": 0.48,
		"slap_upward_impulse": 0.018,
		"slap_torque": 0.014,
		"slap_cooldown": 0.72,
		"slap_active_duration": 0.18,
		"slap_prop_force_multiplier": 1.8,
		"shift_slap_multiplier": 1.2,
		"slap_max_speed": 4.0,
		"slap_ground_clearance_boost": 0.016,
		"slap_camera_bump": 0.04,
		"slap_particle_enabled": true,
		"linear_damping": 0.9,
		"angular_damping": 4.4,
		"max_linear_speed": 3.0,
		"max_angular_speed": 3.4,
		"face_camera_enabled": true,
		"yaw_align_strength": 0.22,
		"yaw_align_damping": 0.13,
		"max_yaw_angular_velocity": 1.9,
		"face_camera_smoothing": 10.0,
		"preserve_pitch_roll": true,
		"alignment_deadzone_degrees": 2.0,
		"air_control_multiplier": 0.13,
		"ground_control_multiplier": 0.95,
	},
	"Playable Physics": {
		"move_force": 2.25,
		"move_impulse": 0.0045,
		"ground_hop_impulse": 0.56,
		"jump_forward_assist": 0.16,
		"max_air_flaps": 4,
		"air_flap_impulse": 0.36,
		"air_flap_torque": 0.045,
		"flap_cooldown": 0.2,
		"max_upward_velocity": 4.3,
		"torque_strength": 0.016,
		"movement_wobble_torque": 0.0035,
		"boost_enabled": true,
		"boost_move_multiplier": 1.42,
		"boost_hop_assist_multiplier": 1.18,
		"boost_wobble_multiplier": 1.35,
		"boost_max_linear_speed": 4.9,
		"boost_max_angular_speed": 5.2,
		"boost_slap_multiplier": 1.18,
		"boost_camera_bump_strength": 0.1,
		"slap_forward_impulse": 0.72,
		"slap_upward_impulse": 0.022,
		"slap_torque": 0.028,
		"slap_cooldown": 0.56,
		"slap_active_duration": 0.22,
		"slap_prop_force_multiplier": 2.7,
		"shift_slap_multiplier": 1.35,
		"slap_max_speed": 5.0,
		"slap_ground_clearance_boost": 0.022,
		"slap_camera_bump": 0.065,
		"slap_particle_enabled": true,
		"linear_damping": 0.62,
		"angular_damping": 3.5,
		"max_linear_speed": 3.9,
		"max_angular_speed": 4.5,
		"face_camera_enabled": true,
		"yaw_align_strength": 0.16,
		"yaw_align_damping": 0.09,
		"max_yaw_angular_velocity": 2.3,
		"face_camera_smoothing": 8.0,
		"preserve_pitch_roll": true,
		"alignment_deadzone_degrees": 3.0,
		"air_control_multiplier": 0.11,
		"ground_control_multiplier": 1.0,
	},
	"Chaotic": {
		"move_force": 3.35,
		"move_impulse": 0.009,
		"ground_hop_impulse": 0.65,
		"jump_forward_assist": 0.22,
		"max_air_flaps": 5,
		"air_flap_impulse": 0.46,
		"air_flap_torque": 0.08,
		"flap_cooldown": 0.16,
		"max_upward_velocity": 5.2,
		"torque_strength": 0.03,
		"movement_wobble_torque": 0.009,
		"boost_enabled": true,
		"boost_move_multiplier": 1.75,
		"boost_hop_assist_multiplier": 1.32,
		"boost_wobble_multiplier": 1.85,
		"boost_max_linear_speed": 6.4,
		"boost_max_angular_speed": 7.0,
		"boost_slap_multiplier": 1.35,
		"boost_camera_bump_strength": 0.15,
		"slap_forward_impulse": 0.95,
		"slap_upward_impulse": 0.035,
		"slap_torque": 0.06,
		"slap_cooldown": 0.38,
		"slap_active_duration": 0.26,
		"slap_prop_force_multiplier": 3.6,
		"shift_slap_multiplier": 1.6,
		"slap_max_speed": 6.4,
		"slap_ground_clearance_boost": 0.032,
		"slap_camera_bump": 0.1,
		"slap_particle_enabled": true,
		"linear_damping": 0.45,
		"angular_damping": 2.3,
		"max_linear_speed": 5.4,
		"max_angular_speed": 6.3,
		"face_camera_enabled": true,
		"yaw_align_strength": 0.08,
		"yaw_align_damping": 0.045,
		"max_yaw_angular_velocity": 3.0,
		"face_camera_smoothing": 5.0,
		"preserve_pitch_roll": true,
		"alignment_deadzone_degrees": 5.0,
		"air_control_multiplier": 0.18,
		"ground_control_multiplier": 1.08,
	},
}

const PRESET_ORDER := ["Gentle", "Playable Physics", "Chaotic"]
const FLIPFLOP_COLOR_OPTIONS := [
	{
		"name": "faded blue",
		"color": Color(0.24, 0.5, 0.74),
	},
	{
		"name": "washed red",
		"color": Color(0.72, 0.24, 0.2),
	},
	{
		"name": "ugly green",
		"color": Color(0.36, 0.58, 0.18),
	},
	{
		"name": "sunburnt yellow",
		"color": Color(0.92, 0.72, 0.22),
	},
	{
		"name": "mysterious golden flipflop",
		"color": Color(1.0, 0.76, 0.22),
	},
]

var current_preset_name: String = "Playable Physics"
var current_flipflop_color_name: String = "faded blue"
var _was_grounded: bool = false
var _touching_ground: bool = false
var _grounded_timer: float = 0.0
var _last_vertical_velocity: float = 0.0
var _space_was_pressed: bool = false
var _reset_was_pressed: bool = false
var _color_cycle_was_pressed: bool = false
var _hop_buffer_timer: float = 0.0
var _flap_cooldown_timer: float = 0.0
var _speed_clamped: bool = false
var _angular_speed_clamped: bool = false
var _debug_timer: float = 0.0
var _raw_move_input: Vector2 = Vector2.ZERO
var _last_input_direction: Vector3 = Vector3.ZERO
var _last_camera_forward: Vector3 = Vector3.FORWARD
var _last_camera_right: Vector3 = Vector3.RIGHT
var _last_move_force_applied: Vector3 = Vector3.ZERO
var _target_yaw_degrees: float = 0.0
var _current_yaw_degrees: float = 0.0
var _yaw_difference_degrees: float = 0.0
var _yaw_alignment_active: bool = false
var _yaw_align_torque_applied: float = 0.0
var _smoothed_target_yaw: float = 0.0
var _has_smoothed_target_yaw: bool = false
var _recovery_cooldown_timer: float = 0.0
var _stuck_recovery_triggered: bool = false
var _flipflop_color_index: int = 0
var _air_flaps_remaining: int = 4
var _last_jump_type: String = "none"
var _boost_active: bool = false
var _current_move_multiplier: float = 1.0
var _current_max_linear_speed: float = 4.2
var _current_max_angular_speed: float = 4.8
var _slap_requested: bool = false
var _slap_cooldown_timer: float = 0.0
var _slap_active_timer: float = 0.0
var _last_slap_direction: Vector3 = Vector3.FORWARD
var _last_slapped_object_name: String = "none"
var _current_slap_strength: float = 0.0
var _shift_slap_active: bool = false
var _slapped_body_ids: Dictionary = {}
var _sole_material: StandardMaterial3D
var _default_surface_settings: Dictionary = {
	"surface_type": "sand",
	"surface_name": "Sand",
	"move_multiplier": 0.88,
	"linear_damping_multiplier": 1.18,
	"angular_damping_multiplier": 1.08,
	"jump_multiplier": 0.94,
	"landing_impact_multiplier": 0.75,
	"landing_sound_type": "sand",
	"particle_type": "sand",
}
var _active_surface_zones: Dictionary = {}
var _surface_zone_order: Array[int] = []
var _current_surface_type: String = "sand"
var _current_surface_name: String = "Sand"
var _surface_move_multiplier: float = 0.88
var _surface_linear_damping_multiplier: float = 1.0
var _surface_angular_damping_multiplier: float = 1.0
var _surface_jump_multiplier: float = 1.0
var _surface_landing_impact_multiplier: float = 1.0
var _surface_landing_sound_type: String = "sand"
var _surface_particle_type: String = "sand"
var _active_water_zones: Dictionary = {}
var _water_zone_order: Array[int] = []
var _is_in_water: bool = false
var _water_timer: float = 0.0
var _water_drag_active: bool = false
var _water_buoyancy_active: bool = false
var _water_soft_reset_triggered: bool = false
var _current_water_surface_y: float = 0.0
var _current_water_safe_exit_position: Vector3 = Vector3(0.0, 0.35, 0.0)
var _current_water_drag_multiplier: float = 2.4
var _current_water_angular_drag_multiplier: float = 2.1
var _current_water_buoyancy_force: float = 0.55
var _current_water_push_to_shore_force: float = 0.24
var _current_water_max_time_before_soft_reset: float = 3.5
var _current_water_spin_damping: float = 0.86
var _current_water_splash_enabled: bool = true


func _input(event: InputEvent) -> void:
	if get_tree().paused:
		return

	var mouse_button: InputEventMouseButton = event as InputEventMouseButton
	if mouse_button == null or not mouse_button.pressed:
		return

	if mouse_button.button_index == MOUSE_BUTTON_LEFT:
		_slap_requested = true


func _ready() -> void:
	apply_movement_preset(current_preset_name)
	_apply_surface_settings(_default_surface_settings)
	_prepare_color_material()
	_apply_flipflop_color(_flipflop_color_index)
	linear_damp = linear_damping
	angular_damp = angular_damping
	contact_monitor = true
	max_contacts_reported = maxi(max_contacts_reported, 8)
	_ground_ray.top_level = true
	_update_ground_ray_position()
	_was_grounded = _is_close_to_ground()
	_touching_ground = _was_grounded
	_air_flaps_remaining = max_air_flaps


func _physics_process(delta: float) -> void:
	linear_damp = linear_damping * _surface_linear_damping_multiplier
	angular_damp = angular_damping * _surface_angular_damping_multiplier
	if _is_in_water:
		linear_damp *= _current_water_drag_multiplier
		angular_damp *= _current_water_angular_drag_multiplier

	_update_ground_ray_position()
	_flap_cooldown_timer = maxf(_flap_cooldown_timer - delta, 0.0)
	_slap_cooldown_timer = maxf(_slap_cooldown_timer - delta, 0.0)
	_slap_active_timer = maxf(_slap_active_timer - delta, 0.0)
	if _slap_active_timer <= 0.0:
		_shift_slap_active = false

	_recovery_cooldown_timer = maxf(_recovery_cooldown_timer - delta, 0.0)
	_stuck_recovery_triggered = false
	_water_soft_reset_triggered = false

	var grounded := _update_grounded_state(delta)
	if _touching_ground:
		_air_flaps_remaining = max_air_flaps

	_boost_active = _is_boost_pressed()
	_current_move_multiplier = _get_current_move_multiplier()
	_current_max_linear_speed = _get_current_max_linear_speed()
	_current_max_angular_speed = _get_current_max_angular_speed()

	var control_multiplier := ground_control_multiplier if grounded else air_control_multiplier
	control_multiplier *= _surface_move_multiplier
	var camera_axes := _get_camera_axes()
	var forward_axis: Vector3 = camera_axes["forward"]
	var right_axis: Vector3 = camera_axes["right"]
	_last_camera_forward = forward_axis
	_last_camera_right = right_axis
	var move_input := _get_move_input()
	_raw_move_input = move_input

	_apply_camera_relative_movement(
		move_input,
		forward_axis,
		right_axis,
		control_multiplier,
		delta
	)
	_apply_face_camera_alignment(forward_axis, delta)
	_apply_twist_controls(control_multiplier)
	_process_slap_request(forward_axis)
	_apply_water_interaction(delta)

	if _was_just_pressed(KEY_SPACE, _space_was_pressed):
		_hop_buffer_timer = hop_input_buffer_time
	else:
		_hop_buffer_timer = maxf(_hop_buffer_timer - delta, 0.0)

	if _hop_buffer_timer > 0.0 and _flap_cooldown_timer <= 0.0:
		if grounded:
			_ground_hop(move_input, forward_axis, right_axis)
			_hop_buffer_timer = 0.0
			_flap_cooldown_timer = flap_cooldown
		elif _air_flaps_remaining > 0:
			_air_flap(move_input, forward_axis, right_axis)
			_hop_buffer_timer = 0.0
			_flap_cooldown_timer = flap_cooldown

	if Input.is_key_pressed(KEY_SPACE) and grounded:
		_apply_upside_down_help(delta)

	if _was_just_pressed(KEY_R, _reset_was_pressed):
		reset_flipflop()

	if _was_just_pressed(KEY_C, _color_cycle_was_pressed):
		cycle_flipflop_color()

	if not _was_grounded and grounded:
		_on_landed(absf(_last_vertical_velocity))

	if global_position.y < fall_reset_height:
		reset_flipflop()

	recover_if_stuck_under_ground()
	_apply_slap_prop_impulses()
	_clamp_upward_velocity()
	_clamp_water_velocity()
	_clamp_yaw_angular_velocity()
	_clamp_velocity()
	_print_debug_if_enabled(delta, grounded)

	_was_grounded = grounded
	_last_vertical_velocity = linear_velocity.y


func _get_camera_axes() -> Dictionary:
	var camera := get_viewport().get_camera_3d()

	if camera != null:
		if camera.has_method("get_camera_yaw_axes"):
			var axes_value: Variant = camera.call("get_camera_yaw_axes")
			if axes_value is Dictionary:
				var axes: Dictionary = axes_value
				var forward_value: Variant = axes.get("forward", Vector3.ZERO)
				var right_value: Variant = axes.get("right", Vector3.ZERO)

				if forward_value is Vector3 and right_value is Vector3:
					var yaw_forward: Vector3 = forward_value
					var yaw_right: Vector3 = right_value
					yaw_forward.y = 0.0
					yaw_right.y = 0.0

					if yaw_forward.length() > 0.001 and yaw_right.length() > 0.001:
						return {
							"forward": yaw_forward.normalized(),
							"right": yaw_right.normalized(),
						}

		# Read the active Camera3D every physics frame. This keeps WASD tied to
		# the current camera view instead of the tumbling flipflop rotation.
		var camera_forward := -camera.global_transform.basis.z
		camera_forward.y = 0.0
		var camera_right := camera.global_transform.basis.x
		camera_right.y = 0.0

		if camera_forward.length() > 0.001 and camera_right.length() > 0.001:
			return {
				"forward": camera_forward.normalized(),
				"right": camera_right.normalized(),
			}

	# Fallback for editor testing without an active camera.
	return {
		"forward": Vector3.FORWARD,
		"right": Vector3.RIGHT,
	}


func _get_move_input() -> Vector2:
	var input := Vector2.ZERO

	if Input.is_key_pressed(KEY_W) or Input.is_key_pressed(KEY_UP):
		input.y += 1.0

	if Input.is_key_pressed(KEY_S) or Input.is_key_pressed(KEY_DOWN):
		input.y -= 1.0

	if Input.is_key_pressed(KEY_D) or Input.is_key_pressed(KEY_RIGHT):
		input.x += 1.0

	if Input.is_key_pressed(KEY_A) or Input.is_key_pressed(KEY_LEFT):
		input.x -= 1.0

	return input.normalized()


func _apply_camera_relative_movement(
	move_input: Vector2,
	forward_axis: Vector3,
	right_axis: Vector3,
	control_multiplier: float,
	delta: float
) -> void:
	_last_input_direction = Vector3.ZERO
	_last_move_force_applied = Vector3.ZERO

	if move_input == Vector2.ZERO:
		return

	var move_direction := _get_camera_relative_move_direction(move_input, forward_axis, right_axis)

	if move_direction.length() < 0.001:
		return

	_last_input_direction = move_direction

	# WASD movement is applied at the center of mass, so pressing W moves across
	# the sand instead of rolling the flipflop like a wheel.
	sleeping = false

	_last_move_force_applied = move_direction * move_force * control_multiplier
	_last_move_force_applied *= _current_move_multiplier
	apply_central_force(_last_move_force_applied)

	if move_impulse > 0.0:
		var frame_safe_impulse := move_impulse * delta * 60.0
		apply_central_impulse(
			move_direction
			* frame_safe_impulse
			* control_multiplier
			* _current_move_multiplier
		)

	# A tiny yaw wobble keeps the object feeling physical without causing
	# constant 360-degree forward rolls.
	if movement_wobble_torque > 0.0:
		var wobble := (move_input.x * 0.75 + randf_range(-0.15, 0.15))
		apply_torque(
			Vector3.UP
			* wobble
			* movement_wobble_torque
			* control_multiplier
			* _get_current_wobble_multiplier()
		)


func _get_camera_relative_move_direction(
	move_input: Vector2,
	forward_axis: Vector3,
	right_axis: Vector3
) -> Vector3:
	if move_input == Vector2.ZERO:
		return Vector3.ZERO

	var move_direction := (
		forward_axis * move_input.y
		+ right_axis * move_input.x
	)

	if move_direction.length() < 0.001:
		return Vector3.ZERO

	return move_direction.normalized()


func _apply_face_camera_alignment(target_forward: Vector3, delta: float) -> void:
	_yaw_alignment_active = false
	_yaw_align_torque_applied = 0.0

	if not face_camera_enabled:
		return

	target_forward.y = 0.0
	if target_forward.length() < 0.001:
		return

	target_forward = target_forward.normalized()
	var target_yaw := _get_yaw_from_direction(target_forward)

	if not _has_smoothed_target_yaw:
		_smoothed_target_yaw = target_yaw
		_has_smoothed_target_yaw = true
	elif face_camera_smoothing > 0.0:
		var smoothing_alpha := 1.0 - exp(-face_camera_smoothing * delta)
		_smoothed_target_yaw = lerp_angle(_smoothed_target_yaw, target_yaw, smoothing_alpha)
	else:
		_smoothed_target_yaw = target_yaw

	var current_forward := -global_transform.basis.z
	current_forward.y = 0.0
	if current_forward.length() < 0.001:
		return

	current_forward = current_forward.normalized()
	var current_yaw := _get_yaw_from_direction(current_forward)
	var yaw_difference := wrapf(_smoothed_target_yaw - current_yaw, -PI, PI)

	_target_yaw_degrees = rad_to_deg(_smoothed_target_yaw)
	_current_yaw_degrees = rad_to_deg(current_yaw)
	_yaw_difference_degrees = rad_to_deg(yaw_difference)

	if absf(_yaw_difference_degrees) <= alignment_deadzone_degrees:
		return

	var torque_amount := (
		yaw_difference
		* yaw_align_strength
		- angular_velocity.y
		* yaw_align_damping
	)

	if max_yaw_angular_velocity > 0.0:
		if angular_velocity.y >= max_yaw_angular_velocity and torque_amount > 0.0:
			torque_amount = 0.0
		elif angular_velocity.y <= -max_yaw_angular_velocity and torque_amount < 0.0:
			torque_amount = 0.0

	if absf(torque_amount) < 0.0001:
		return

	# Default behavior is pure world-Y torque, which preserves the funny
	# pitch/roll wobble from physics while correcting readable facing direction.
	var torque_axis := Vector3.UP
	if not preserve_pitch_roll:
		torque_axis = global_transform.basis.y.normalized()

	apply_torque(torque_axis * torque_amount)
	_yaw_alignment_active = true
	_yaw_align_torque_applied = torque_amount


func _get_yaw_from_direction(direction: Vector3) -> float:
	var flat_direction := direction
	flat_direction.y = 0.0

	if flat_direction.length() < 0.001:
		return 0.0

	flat_direction = flat_direction.normalized()
	return atan2(flat_direction.x, flat_direction.z)


func _apply_twist_controls(control_multiplier: float) -> void:
	var input := 0.0

	if Input.is_key_pressed(KEY_Q):
		input += 1.0

	if Input.is_key_pressed(KEY_E):
		input -= 1.0

	if input == 0.0:
		return

	apply_torque_impulse(Vector3.UP * input * torque_strength * control_multiplier)


func _process_slap_request(forward_axis: Vector3) -> void:
	if not _slap_requested:
		return

	_slap_requested = false

	if _slap_cooldown_timer > 0.0:
		return

	_perform_slap(forward_axis)


func _perform_slap(forward_axis: Vector3) -> void:
	var slap_direction := forward_axis
	slap_direction.y = 0.0

	if slap_direction.length() < 0.001:
		slap_direction = Vector3.FORWARD
	else:
		slap_direction = slap_direction.normalized()

	var slap_multiplier := _get_current_slap_attack_multiplier()
	_current_slap_strength = slap_forward_impulse * slap_multiplier
	_last_slap_direction = slap_direction
	_last_slapped_object_name = "none"
	_slapped_body_ids.clear()
	sleeping = false

	# The attack is a forward central impulse, separate from Space hop/flap.
	# Keeping it at center of mass makes the sandal lunge across the ground
	# instead of popping upward or rolling like a wheel.
	apply_central_impulse(slap_direction * _current_slap_strength)

	var upward_clearance := slap_upward_impulse
	if _touching_ground or _grounded_timer > 0.0:
		upward_clearance += slap_ground_clearance_boost

	apply_central_impulse(Vector3.UP * upward_clearance * slap_multiplier)
	apply_torque_impulse(Vector3(
		randf_range(-slap_torque, slap_torque),
		randf_range(-slap_torque * 0.5, slap_torque * 0.5),
		randf_range(-slap_torque, slap_torque)
	) * slap_multiplier)

	if linear_velocity.length() > slap_max_speed:
		linear_velocity = linear_velocity.normalized() * slap_max_speed

	_slap_active_timer = slap_active_duration
	_slap_cooldown_timer = slap_cooldown
	play_slap_attack_sound(slap_multiplier)

	if slap_particle_enabled:
		spawn_slap_sand_burst(slap_multiplier)

	trigger_camera_bump(slap_camera_bump * slap_multiplier)


func _ground_hop(move_input: Vector2, forward_axis: Vector3, right_axis: Vector3) -> void:
	# Trim downward speed before hopping so Space feels responsive near the sand
	# without letting the flipflop stack huge upward launches.
	if linear_velocity.y < 0.0:
		var velocity := linear_velocity
		velocity.y *= 0.2
		linear_velocity = velocity

	sleeping = false
	apply_central_impulse(Vector3.UP * ground_hop_impulse * _surface_jump_multiplier)

	var move_direction := _get_camera_relative_move_direction(move_input, forward_axis, right_axis)
	if move_direction != Vector3.ZERO and jump_forward_assist > 0.0:
		apply_central_impulse(
			move_direction
			* jump_forward_assist
			* _get_current_hop_assist_multiplier()
			* _surface_move_multiplier
		)

	# Add a tiny random tumble so hops land differently without becoming wild.
	apply_torque_impulse(Vector3(
		randf_range(-torque_strength, torque_strength),
		randf_range(-torque_strength, torque_strength),
		randf_range(-torque_strength, torque_strength)
	) * 1.4)
	_grounded_timer = 0.0
	_last_jump_type = "ground_hop"
	_clamp_upward_velocity()


func _air_flap(move_input: Vector2, forward_axis: Vector3, right_axis: Vector3) -> void:
	if _air_flaps_remaining <= 0:
		return

	_air_flaps_remaining -= 1
	sleeping = false

	# Soften falling speed before the air flap. This makes repeated Space taps
	# useful for recovery and climbing without building infinite vertical speed.
	if linear_velocity.y < 0.0:
		var velocity := linear_velocity
		velocity.y *= 0.25
		linear_velocity = velocity

	apply_central_impulse(Vector3.UP * air_flap_impulse * _surface_jump_multiplier)

	var move_direction := _get_camera_relative_move_direction(move_input, forward_axis, right_axis)
	if move_direction != Vector3.ZERO and jump_forward_assist > 0.0:
		apply_central_impulse(
			move_direction
			* jump_forward_assist
			* _get_current_hop_assist_multiplier()
			* _surface_move_multiplier
		)

	# The air flap is intentionally messy: a small random torque sells the
	# "loose sandal flailing in the air" feeling without driving movement.
	apply_torque_impulse(Vector3(
		randf_range(-air_flap_torque, air_flap_torque),
		randf_range(-air_flap_torque * 0.75, air_flap_torque * 0.75),
		randf_range(-air_flap_torque, air_flap_torque)
	))
	_last_jump_type = "air_flap"
	_clamp_upward_velocity()


func _apply_upside_down_help(_delta: float) -> void:
	var local_up := global_transform.basis.y.normalized()
	var upright_amount := local_up.dot(Vector3.UP)

	# Close to upright is fine. Sideways or upside down gets a player-requested
	# helper nudge while Space is held.
	if upright_amount > 0.35:
		return

	var correction_axis := local_up.cross(Vector3.UP)

	if correction_axis.length() < 0.001:
		correction_axis = global_transform.basis.x.normalized()
	else:
		correction_axis = correction_axis.normalized()

	apply_torque(correction_axis * upside_down_help_strength)


func _update_grounded_state(delta: float) -> bool:
	_touching_ground = _is_close_to_ground()

	if _touching_ground:
		_grounded_timer = grounded_grace_time
	else:
		_grounded_timer = maxf(_grounded_timer - delta, 0.0)

	return _grounded_timer > 0.0


func _update_ground_ray_position() -> void:
	# Keep the ray world-aligned instead of rotating with the tumbling flipflop.
	_ground_ray.global_position = global_position
	_ground_ray.global_rotation = Vector3.ZERO
	_ground_ray.target_position = Vector3.DOWN * ground_check_distance


func _is_close_to_ground() -> bool:
	_ground_ray.force_raycast_update()
	return _ground_ray.is_colliding()


func _was_just_pressed(key: Key, was_pressed: bool) -> bool:
	var is_pressed := Input.is_key_pressed(key)
	var just_pressed := is_pressed and not was_pressed

	if key == KEY_SPACE:
		_space_was_pressed = is_pressed
	elif key == KEY_R:
		_reset_was_pressed = is_pressed
	elif key == KEY_C:
		_color_cycle_was_pressed = is_pressed

	return just_pressed


func _is_boost_pressed() -> bool:
	return boost_enabled and Input.is_key_pressed(KEY_SHIFT)


func _get_current_move_multiplier() -> float:
	if _boost_active:
		return boost_move_multiplier

	return 1.0


func _get_current_hop_assist_multiplier() -> float:
	if _boost_active:
		return boost_hop_assist_multiplier

	return 1.0


func _get_current_wobble_multiplier() -> float:
	if _boost_active:
		return boost_wobble_multiplier

	return 1.0


func _get_current_slap_multiplier() -> float:
	if _boost_active:
		return boost_slap_multiplier

	return 1.0


func _get_current_slap_attack_multiplier() -> float:
	_shift_slap_active = Input.is_key_pressed(KEY_SHIFT)

	if _shift_slap_active:
		return shift_slap_multiplier

	return 1.0


func _get_current_max_linear_speed() -> float:
	var speed_limit := max_linear_speed

	if _boost_active:
		speed_limit = boost_max_linear_speed

	if _slap_active_timer > 0.0:
		speed_limit = maxf(speed_limit, slap_max_speed)

	return speed_limit


func _get_current_max_angular_speed() -> float:
	if _boost_active:
		return boost_max_angular_speed

	return max_angular_speed


func _clamp_upward_velocity() -> void:
	# Repeated Space taps should help the flipflop climb and recover, but this
	# cap prevents Flappy Bird-style flaps from stacking into endless flight.
	if linear_velocity.y <= max_upward_velocity:
		return

	var velocity := linear_velocity
	velocity.y = max_upward_velocity
	linear_velocity = velocity


func _clamp_velocity() -> void:
	_speed_clamped = false
	_angular_speed_clamped = false

	_current_max_linear_speed = _get_current_max_linear_speed()
	_current_max_angular_speed = _get_current_max_angular_speed()

	if linear_velocity.length() > _current_max_linear_speed:
		linear_velocity = linear_velocity.normalized() * _current_max_linear_speed
		_speed_clamped = true

	if angular_velocity.length() > _current_max_angular_speed:
		angular_velocity = angular_velocity.normalized() * _current_max_angular_speed
		_angular_speed_clamped = true


func _clamp_water_velocity() -> void:
	if not _is_in_water:
		return

	if linear_velocity.length() > water_max_linear_speed:
		linear_velocity = linear_velocity.normalized() * water_max_linear_speed

	if angular_velocity.length() > water_max_angular_speed:
		angular_velocity = angular_velocity.normalized() * water_max_angular_speed


func _clamp_yaw_angular_velocity() -> void:
	if max_yaw_angular_velocity <= 0.0:
		return

	if absf(angular_velocity.y) <= max_yaw_angular_velocity:
		return

	var velocity := angular_velocity
	if velocity.y > 0.0:
		velocity.y = max_yaw_angular_velocity
	else:
		velocity.y = -max_yaw_angular_velocity

	angular_velocity = velocity


func _apply_water_interaction(delta: float) -> void:
	_water_drag_active = false
	_water_buoyancy_active = false

	if not _is_in_water:
		_water_timer = 0.0
		return

	_water_timer += delta
	sleeping = false

	var horizontal_velocity := Vector3(linear_velocity.x, 0.0, linear_velocity.z)
	if horizontal_velocity.length() > 0.001:
		# Drag is a smooth opposing force. It slows sliding without creating a
		# hard collision response or repeated impulse spikes.
		apply_central_force(
			-horizontal_velocity
			* _current_water_drag_multiplier
			* mass
		)
		_water_drag_active = true

	var spin_damping := clampf(_current_water_spin_damping, 0.0, 1.0)
	angular_velocity *= pow(spin_damping, delta * 60.0)

	if angular_velocity.length() > 0.001:
		apply_torque(
			-angular_velocity
			* _current_water_angular_drag_multiplier
			* mass
		)

	var depth := maxf(0.0, _current_water_surface_y - global_position.y)
	if global_position.y < _current_water_surface_y + 0.18:
		var buoyancy_scale := 1.0 + minf(depth, 1.2)
		apply_central_force(
			Vector3.UP
			* _current_water_buoyancy_force
			* buoyancy_scale
			* mass
		)
		_water_buoyancy_active = true

	var shore_direction := _current_water_safe_exit_position - global_position
	shore_direction.y = 0.0
	if shore_direction.length() > 0.1 and _current_water_push_to_shore_force > 0.0:
		apply_central_force(
			shore_direction.normalized()
			* _current_water_push_to_shore_force
			* mass
		)

	if (
		_water_timer >= _current_water_max_time_before_soft_reset
		or global_position.y < _current_water_surface_y - water_soft_reset_depth
	):
		_soft_reset_from_water()


func enter_water_zone(
	zone_water_surface_y: float = 0.0,
	zone_water_safe_exit_position: Vector3 = Vector3.ZERO,
	zone_water_drag_multiplier: float = 0.0,
	zone_water_angular_drag_multiplier: float = 0.0,
	zone_water_buoyancy_force: float = 0.0,
	zone_water_push_to_shore_force: float = 0.0,
	zone_water_max_time_before_soft_reset: float = 0.0,
	zone_water_spin_damping: float = -1.0,
	zone_splash_enabled: bool = true,
	source_id: int = 0
) -> void:
	var zone_id := source_id
	if zone_id == 0:
		zone_id = get_instance_id()

	_active_water_zones[zone_id] = _make_water_settings(
		zone_water_surface_y,
		zone_water_safe_exit_position,
		zone_water_drag_multiplier,
		zone_water_angular_drag_multiplier,
		zone_water_buoyancy_force,
		zone_water_push_to_shore_force,
		zone_water_max_time_before_soft_reset,
		zone_water_spin_damping,
		zone_splash_enabled
	)
	_water_zone_order.erase(zone_id)
	_water_zone_order.append(zone_id)
	_select_current_water_zone()

	if _current_water_splash_enabled:
		play_surface_landing_sound("water", 1.0)
		spawn_water_splash_particles(1.0)


func exit_water_zone(source_id: int = 0) -> void:
	if source_id != 0:
		_active_water_zones.erase(source_id)
		_water_zone_order.erase(source_id)
	else:
		_active_water_zones.clear()
		_water_zone_order.clear()

	_select_current_water_zone()


func _make_water_settings(
	zone_water_surface_y: float,
	zone_water_safe_exit_position: Vector3,
	zone_water_drag_multiplier: float,
	zone_water_angular_drag_multiplier: float,
	zone_water_buoyancy_force: float,
	zone_water_push_to_shore_force: float,
	zone_water_max_time_before_soft_reset: float,
	zone_water_spin_damping: float,
	zone_splash_enabled: bool
) -> Dictionary:
	var resolved_safe_exit := zone_water_safe_exit_position
	if resolved_safe_exit == Vector3.ZERO:
		resolved_safe_exit = water_safe_exit_position

	return {
		"water_surface_y": zone_water_surface_y,
		"water_safe_exit_position": resolved_safe_exit,
		"water_drag_multiplier": (
			zone_water_drag_multiplier
			if zone_water_drag_multiplier > 0.0
			else water_drag_multiplier
		),
		"water_angular_drag_multiplier": (
			zone_water_angular_drag_multiplier
			if zone_water_angular_drag_multiplier > 0.0
			else water_angular_drag_multiplier
		),
		"water_buoyancy_force": (
			zone_water_buoyancy_force
			if zone_water_buoyancy_force > 0.0
			else water_buoyancy_force
		),
		"water_push_to_shore_force": (
			zone_water_push_to_shore_force
			if zone_water_push_to_shore_force > 0.0
			else water_push_to_shore_force
		),
		"water_max_time_before_soft_reset": (
			zone_water_max_time_before_soft_reset
			if zone_water_max_time_before_soft_reset > 0.0
			else water_max_time_before_soft_reset
		),
		"water_spin_damping": (
			zone_water_spin_damping
			if zone_water_spin_damping >= 0.0
			else water_spin_damping
		),
		"splash_enabled": zone_splash_enabled and splash_enabled,
	}


func _select_current_water_zone() -> void:
	while not _water_zone_order.is_empty():
		var zone_id: int = _water_zone_order[_water_zone_order.size() - 1]
		if _active_water_zones.has(zone_id):
			var settings: Dictionary = _active_water_zones[zone_id]
			_apply_water_settings(settings)
			return

		_water_zone_order.pop_back()

	_clear_water_state()


func _apply_water_settings(settings: Dictionary) -> void:
	_is_in_water = true
	_current_water_surface_y = float(settings.get("water_surface_y", water_surface_y))
	var safe_exit_value: Variant = settings.get("water_safe_exit_position", water_safe_exit_position)
	if safe_exit_value is Vector3:
		_current_water_safe_exit_position = safe_exit_value
	else:
		_current_water_safe_exit_position = water_safe_exit_position
	_current_water_drag_multiplier = float(
		settings.get("water_drag_multiplier", water_drag_multiplier)
	)
	_current_water_angular_drag_multiplier = float(
		settings.get("water_angular_drag_multiplier", water_angular_drag_multiplier)
	)
	_current_water_buoyancy_force = float(
		settings.get("water_buoyancy_force", water_buoyancy_force)
	)
	_current_water_push_to_shore_force = float(
		settings.get("water_push_to_shore_force", water_push_to_shore_force)
	)
	_current_water_max_time_before_soft_reset = float(
		settings.get(
			"water_max_time_before_soft_reset",
			water_max_time_before_soft_reset
		)
	)
	_current_water_spin_damping = float(settings.get("water_spin_damping", water_spin_damping))
	_current_water_splash_enabled = bool(settings.get("splash_enabled", splash_enabled))


func _clear_water_state() -> void:
	_active_water_zones.clear()
	_water_zone_order.clear()
	_is_in_water = false
	_water_timer = 0.0
	_water_drag_active = false
	_water_buoyancy_active = false
	_current_water_surface_y = water_surface_y
	_current_water_safe_exit_position = water_safe_exit_position
	_current_water_drag_multiplier = water_drag_multiplier
	_current_water_angular_drag_multiplier = water_angular_drag_multiplier
	_current_water_buoyancy_force = water_buoyancy_force
	_current_water_push_to_shore_force = water_push_to_shore_force
	_current_water_max_time_before_soft_reset = water_max_time_before_soft_reset
	_current_water_spin_damping = water_spin_damping
	_current_water_splash_enabled = splash_enabled


func _soft_reset_from_water() -> void:
	var safe_position := _current_water_safe_exit_position
	safe_position.y = maxf(
		maxf(safe_position.y, safe_ground_y + safe_ground_clearance),
		_current_water_surface_y + safe_ground_clearance
	)
	global_position = safe_position
	global_rotation_degrees = reset_rotation_degrees
	linear_velocity = Vector3.ZERO
	angular_velocity = Vector3.ZERO
	_hop_buffer_timer = 0.0
	_flap_cooldown_timer = 0.0
	_air_flaps_remaining = max_air_flaps
	_last_jump_type = "none"
	_slap_requested = false
	_slap_active_timer = 0.0
	_shift_slap_active = false
	_slapped_body_ids.clear()
	_clear_water_state()
	_clear_surface_zone()
	_water_soft_reset_triggered = true
	sleeping = false

	if debug_movement:
		print("Flipflop softly reset from water to ", safe_position)


func _apply_slap_prop_impulses() -> void:
	if _slap_active_timer <= 0.0:
		return

	var bodies: Array = get_colliding_bodies()

	for body in bodies:
		var prop_body: RigidBody3D = body as RigidBody3D
		if prop_body == null or prop_body == self:
			continue

		var body_id: int = prop_body.get_instance_id()
		if _slapped_body_ids.has(body_id):
			continue

		_slapped_body_ids[body_id] = true
		var prop_direction: Vector3 = _get_slap_prop_direction(prop_body)
		var prop_impulse: float = _current_slap_strength * slap_prop_force_multiplier

		if prop_body.has_method("receive_slap_impulse"):
			prop_body.call("receive_slap_impulse", prop_direction, prop_impulse)
		else:
			prop_body.sleeping = false
			prop_body.apply_central_impulse(prop_direction * prop_impulse)

		_last_slapped_object_name = _get_slapped_object_name(prop_body)


func _get_slap_prop_direction(prop_body: Node3D) -> Vector3:
	var away_direction := prop_body.global_position - global_position
	away_direction.y = 0.0

	if away_direction.length() > 0.001:
		return (_last_slap_direction + away_direction.normalized() * 0.35).normalized()

	return _last_slap_direction


func _get_slapped_object_name(prop_body: Node) -> String:
	if prop_body.has_method("get_debug_label"):
		var label_value: Variant = prop_body.call("get_debug_label")
		return String(label_value)

	return prop_body.name


func recover_if_stuck_under_ground() -> void:
	if _recovery_cooldown_timer > 0.0:
		return

	# Water zones handle their own drag, buoyancy, shore push, and soft reset.
	# Running the sand unstuck helper while in water can cause jitter because
	# the flipflop is allowed to sit slightly below the normal sand height.
	if _is_in_water:
		return

	var minimum_safe_y := safe_ground_y - stuck_recovery_depth

	if global_position.y >= minimum_safe_y:
		return

	var recovered_position := global_position
	recovered_position.y = safe_ground_y + safe_ground_clearance
	global_position = recovered_position

	if linear_velocity.y < 0.0:
		var velocity := linear_velocity
		velocity.y = 0.0
		velocity.x *= recovery_velocity_scale
		velocity.z *= recovery_velocity_scale
		linear_velocity = velocity
	else:
		linear_velocity *= recovery_velocity_scale

	angular_velocity *= recovery_velocity_scale
	_grounded_timer = 0.0
	_hop_buffer_timer = 0.0
	_flap_cooldown_timer = 0.0
	_air_flaps_remaining = max_air_flaps
	_slap_requested = false
	_slap_active_timer = 0.0
	_shift_slap_active = false
	_recovery_cooldown_timer = stuck_recovery_cooldown
	_stuck_recovery_triggered = true
	sleeping = false

	if debug_movement:
		print("Flipflop recovered from under sand at Y=", snappedf(global_position.y, 0.01))


func _print_debug_if_enabled(delta: float, grounded: bool) -> void:
	if not debug_movement:
		return

	_debug_timer -= delta

	if _debug_timer > 0.0:
		return

	_debug_timer = debug_print_interval
	print(
		"Flipflop speed=",
		snappedf(linear_velocity.length(), 0.01),
		" grounded=",
		grounded,
		" angular_speed=",
		snappedf(angular_velocity.length(), 0.01),
		" linear_velocity=",
		linear_velocity,
		" y=",
		snappedf(global_position.y, 0.01),
		" safe_ground_y=",
		safe_ground_y,
		" recovered=",
		_stuck_recovery_triggered,
		" flap_cooldown=",
		snappedf(_flap_cooldown_timer, 0.01),
		" boost=",
		_boost_active,
		" move_multiplier=",
		snappedf(_current_move_multiplier, 0.01),
		" current_max_speed=",
		snappedf(_current_max_linear_speed, 0.01),
		" slap_cooldown=",
		snappedf(_slap_cooldown_timer, 0.01),
		" slap_active=",
		_slap_active_timer > 0.0,
		" slap_strength=",
		snappedf(_current_slap_strength, 0.01),
		" slapped=",
		_last_slapped_object_name,
		" vertical_velocity=",
		snappedf(linear_velocity.y, 0.01),
		" max_upward_velocity=",
		snappedf(max_upward_velocity, 0.01),
		" air_flaps=",
		_air_flaps_remaining,
		" last_jump=",
		_last_jump_type,
		" input_dir=",
		_last_input_direction,
		" raw_input=",
		_raw_move_input,
		" force=",
		_last_move_force_applied,
		" sleeping=",
		sleeping,
		" speed_clamped=",
		_speed_clamped,
		" angular_clamped=",
		_angular_speed_clamped,
		" in_water=",
		_is_in_water,
		" water_timer=",
		snappedf(_water_timer, 0.01),
		" water_drag=",
		_water_drag_active,
		" water_buoyancy=",
		_water_buoyancy_active,
		" water_reset=",
		_water_soft_reset_triggered
	)


func apply_movement_preset(preset_name: String) -> void:
	if preset_name == "Normal":
		preset_name = "Playable Physics"

	if not MOVEMENT_PRESETS.has(preset_name):
		return

	var preset: Dictionary = MOVEMENT_PRESETS[preset_name]
	current_preset_name = preset_name
	move_force = float(preset["move_force"])
	move_impulse = float(preset["move_impulse"])
	ground_hop_impulse = float(preset["ground_hop_impulse"])
	jump_forward_assist = float(preset["jump_forward_assist"])
	max_air_flaps = int(preset["max_air_flaps"])
	air_flap_impulse = float(preset["air_flap_impulse"])
	air_flap_torque = float(preset["air_flap_torque"])
	flap_cooldown = float(preset["flap_cooldown"])
	max_upward_velocity = float(preset["max_upward_velocity"])
	torque_strength = float(preset["torque_strength"])
	movement_wobble_torque = float(preset["movement_wobble_torque"])
	boost_enabled = bool(preset["boost_enabled"])
	boost_move_multiplier = float(preset["boost_move_multiplier"])
	boost_hop_assist_multiplier = float(preset["boost_hop_assist_multiplier"])
	boost_wobble_multiplier = float(preset["boost_wobble_multiplier"])
	boost_max_linear_speed = float(preset["boost_max_linear_speed"])
	boost_max_angular_speed = float(preset["boost_max_angular_speed"])
	boost_slap_multiplier = float(preset["boost_slap_multiplier"])
	boost_camera_bump_strength = float(preset["boost_camera_bump_strength"])
	slap_forward_impulse = float(preset["slap_forward_impulse"])
	slap_upward_impulse = float(preset["slap_upward_impulse"])
	slap_torque = float(preset["slap_torque"])
	slap_cooldown = float(preset["slap_cooldown"])
	slap_active_duration = float(preset["slap_active_duration"])
	slap_prop_force_multiplier = float(preset["slap_prop_force_multiplier"])
	shift_slap_multiplier = float(preset["shift_slap_multiplier"])
	slap_max_speed = float(preset["slap_max_speed"])
	slap_ground_clearance_boost = float(preset["slap_ground_clearance_boost"])
	slap_camera_bump = float(preset["slap_camera_bump"])
	slap_particle_enabled = bool(preset["slap_particle_enabled"])
	linear_damping = float(preset["linear_damping"])
	angular_damping = float(preset["angular_damping"])
	max_linear_speed = float(preset["max_linear_speed"])
	max_angular_speed = float(preset["max_angular_speed"])
	face_camera_enabled = bool(preset["face_camera_enabled"])
	yaw_align_strength = float(preset["yaw_align_strength"])
	yaw_align_damping = float(preset["yaw_align_damping"])
	max_yaw_angular_velocity = float(preset["max_yaw_angular_velocity"])
	face_camera_smoothing = float(preset["face_camera_smoothing"])
	preserve_pitch_roll = bool(preset["preserve_pitch_roll"])
	alignment_deadzone_degrees = float(preset["alignment_deadzone_degrees"])
	air_control_multiplier = float(preset["air_control_multiplier"])
	ground_control_multiplier = float(preset["ground_control_multiplier"])

	if _touching_ground or _grounded_timer > 0.0:
		_air_flaps_remaining = max_air_flaps
	else:
		_air_flaps_remaining = mini(_air_flaps_remaining, max_air_flaps)


func cycle_movement_preset() -> void:
	var current_index := PRESET_ORDER.find(current_preset_name)

	if current_index == -1:
		current_index = 0
	else:
		current_index = (current_index + 1) % PRESET_ORDER.size()

	apply_movement_preset(PRESET_ORDER[current_index])


func get_movement_debug_state() -> Dictionary:
	return {
		"preset": current_preset_name,
		"flipflop_color": current_flipflop_color_name,
		"linear_speed": linear_velocity.length(),
		"angular_speed": angular_velocity.length(),
		"grounded": _grounded_timer > 0.0,
		"player_y": global_position.y,
		"safe_ground_y": safe_ground_y,
		"stuck_recovery_triggered": _stuck_recovery_triggered,
		"collision_contacts": get_contact_count(),
		"flap_cooldown": _flap_cooldown_timer,
		"jump_cooldown": _flap_cooldown_timer,
		"vertical_velocity": linear_velocity.y,
		"air_flaps_remaining": _air_flaps_remaining,
		"max_air_flaps": max_air_flaps,
		"last_jump_type": _last_jump_type,
		"raw_move_input": _raw_move_input,
		"input_direction": _last_input_direction,
		"camera_forward": _last_camera_forward,
		"camera_right": _last_camera_right,
		"move_force_applied": _last_move_force_applied,
		"linear_velocity": linear_velocity,
		"speed_clamped": _speed_clamped,
		"sleeping": sleeping,
		"boost_active": _boost_active,
		"current_move_multiplier": _current_move_multiplier,
		"current_max_speed": _current_max_linear_speed,
		"current_max_linear_speed": _current_max_linear_speed,
		"current_max_angular_speed": _current_max_angular_speed,
		"slap_cooldown": _slap_cooldown_timer,
		"slap_active": _slap_active_timer > 0.0,
		"shift_slap_active": _shift_slap_active,
		"current_slap_direction": _last_slap_direction,
		"last_slapped_object_name": _last_slapped_object_name,
		"current_slap_strength": _current_slap_strength,
		"move_impulse": move_impulse,
		"move_force": move_force,
		"ground_hop_impulse": ground_hop_impulse,
		"jump_forward_assist": jump_forward_assist,
		"air_flap_impulse": air_flap_impulse,
		"air_flap_torque": air_flap_torque,
		"flap_cooldown_time": flap_cooldown,
		"max_upward_velocity": max_upward_velocity,
		"torque_strength": torque_strength,
		"movement_wobble_torque": movement_wobble_torque,
		"boost_enabled": boost_enabled,
		"boost_move_multiplier": boost_move_multiplier,
		"boost_hop_assist_multiplier": boost_hop_assist_multiplier,
		"boost_wobble_multiplier": boost_wobble_multiplier,
		"boost_max_linear_speed": boost_max_linear_speed,
		"boost_max_angular_speed": boost_max_angular_speed,
		"boost_slap_multiplier": boost_slap_multiplier,
		"boost_camera_bump_strength": boost_camera_bump_strength,
		"slap_forward_impulse": slap_forward_impulse,
		"slap_upward_impulse": slap_upward_impulse,
		"slap_torque": slap_torque,
		"slap_cooldown_time": slap_cooldown,
		"slap_active_duration": slap_active_duration,
		"slap_prop_force_multiplier": slap_prop_force_multiplier,
		"shift_slap_multiplier": shift_slap_multiplier,
		"slap_max_speed": slap_max_speed,
		"slap_ground_clearance_boost": slap_ground_clearance_boost,
		"slap_camera_bump": slap_camera_bump,
		"slap_particle_enabled": slap_particle_enabled,
		"linear_damping": linear_damping,
		"angular_damping": angular_damping,
		"max_linear_speed": max_linear_speed,
		"max_angular_speed": max_angular_speed,
		"face_camera_enabled": face_camera_enabled,
		"target_yaw": _target_yaw_degrees,
		"current_yaw": _current_yaw_degrees,
		"yaw_difference": _yaw_difference_degrees,
		"yaw_align_strength": yaw_align_strength,
		"yaw_align_damping": yaw_align_damping,
		"max_yaw_angular_velocity": max_yaw_angular_velocity,
		"face_camera_smoothing": face_camera_smoothing,
		"preserve_pitch_roll": preserve_pitch_roll,
		"alignment_deadzone_degrees": alignment_deadzone_degrees,
		"yaw_alignment_active": _yaw_alignment_active,
		"yaw_align_torque_applied": _yaw_align_torque_applied,
		"surface_type": _current_surface_type,
		"surface_name": _current_surface_name,
		"surface_move_multiplier": _surface_move_multiplier,
		"surface_control_multiplier": _surface_move_multiplier,
		"surface_linear_damping_multiplier": _surface_linear_damping_multiplier,
		"surface_angular_damping_multiplier": _surface_angular_damping_multiplier,
		"surface_damping_multiplier": _surface_linear_damping_multiplier,
		"surface_jump_multiplier": _surface_jump_multiplier,
		"surface_landing_impact_multiplier": _surface_landing_impact_multiplier,
		"surface_landing_sound_type": _surface_landing_sound_type,
		"surface_particle_type": _surface_particle_type,
		"in_water": _is_in_water,
		"water_timer": _water_timer,
		"water_drag_active": _water_drag_active,
		"water_buoyancy_active": _water_buoyancy_active,
		"water_reset_timer": maxf(
			_current_water_max_time_before_soft_reset - _water_timer,
			0.0
		),
		"water_surface_y": _current_water_surface_y,
		"water_safe_exit_position": _current_water_safe_exit_position,
		"water_soft_reset_triggered": _water_soft_reset_triggered,
		"water_drag_multiplier": _current_water_drag_multiplier,
		"water_angular_drag_multiplier": _current_water_angular_drag_multiplier,
		"water_buoyancy_force": _current_water_buoyancy_force,
		"water_push_to_shore_force": _current_water_push_to_shore_force,
		"water_spin_damping": _current_water_spin_damping,
		"water_max_time_before_soft_reset": _current_water_max_time_before_soft_reset,
		"angular_velocity": angular_velocity,
	}


func cycle_flipflop_color() -> void:
	_flipflop_color_index = (_flipflop_color_index + 1) % FLIPFLOP_COLOR_OPTIONS.size()
	_apply_flipflop_color(_flipflop_color_index)


func _prepare_color_material() -> void:
	if _sole_mesh == null:
		return

	var material := _sole_mesh.get_active_material(0) as StandardMaterial3D
	if material == null:
		_sole_material = StandardMaterial3D.new()
	else:
		_sole_material = material.duplicate() as StandardMaterial3D

	_sole_mesh.set_surface_override_material(0, _sole_material)


func _apply_flipflop_color(color_index: int) -> void:
	if FLIPFLOP_COLOR_OPTIONS.is_empty():
		return

	var option: Dictionary = FLIPFLOP_COLOR_OPTIONS[color_index]
	current_flipflop_color_name = String(option["name"])

	if _sole_material != null:
		var selected_color: Color = option["color"]
		_sole_material.albedo_color = selected_color


func _on_landed(impact_speed: float) -> void:
	var surface_adjusted_impact := impact_speed * _surface_landing_impact_multiplier
	if surface_adjusted_impact < landing_slap_threshold:
		return

	# Hard landing hook. These functions are placeholders for real feedback.
	var slap_multiplier := _get_current_slap_multiplier()
	play_surface_landing_sound(_surface_landing_sound_type, slap_multiplier)
	spawn_surface_landing_particles(_surface_particle_type, slap_multiplier)

	if _boost_active:
		trigger_camera_bump(boost_camera_bump_strength)
	else:
		trigger_camera_bump()

	# TODO: Add a water splash if the landing point is in shallow water.
	# TODO: Add extra wave push feedback when surf hits the flipflop.


func play_slap_sound(_slap_multiplier: float = 1.0) -> void:
	# Safe placeholder hook. If the ambience audio node has no stream assigned,
	# this call quietly does nothing.
	var audio := get_tree().get_first_node_in_group("ambience_audio")
	if audio != null and audio.has_method("play_slap_sound"):
		audio.call("play_slap_sound")


func play_surface_landing_sound(sound_type: String, slap_multiplier: float = 1.0) -> void:
	# Placeholder routing for surface-specific landing sounds.
	# Real audio can later split these into sand thuds, tile slaps, wood clacks,
	# and water splashes without changing the movement code.
	var audio := get_tree().get_first_node_in_group("ambience_audio")

	match sound_type:
		"water", "wet_tile":
			if audio != null and audio.has_method("play_pool_splash"):
				audio.call("play_pool_splash")
			else:
				play_slap_sound(slap_multiplier)
		"wood", "dry_tile", "sand", "default":
			play_slap_sound(slap_multiplier)
		_:
			play_slap_sound(slap_multiplier)


func spawn_sand_particles(_slap_multiplier: float = 1.0) -> void:
	# TODO: Spawn a small sand puff GPUParticles3D effect.
	pass


func spawn_surface_landing_particles(particle_type: String, slap_multiplier: float = 1.0) -> void:
	match particle_type:
		"sand":
			spawn_sand_particles(slap_multiplier)
		"splash":
			spawn_water_splash_particles(slap_multiplier)
		"dust":
			spawn_dust_particles(slap_multiplier)
		_:
			pass


func spawn_water_splash_particles(_slap_multiplier: float = 1.0) -> void:
	# TODO: Spawn a small tile/water splash particle puff.
	pass


func spawn_dust_particles(_slap_multiplier: float = 1.0) -> void:
	# TODO: Spawn a tiny dry tile or wood dust fleck effect.
	pass


func play_slap_attack_sound(_slap_multiplier: float = 1.0) -> void:
	# Placeholder slap/lunge sound hook. This currently reuses the safe ambience
	# slap player if one exists; real slap attack audio can be assigned later.
	var audio := get_tree().get_first_node_in_group("ambience_audio")
	if audio != null and audio.has_method("play_slap_sound"):
		audio.call("play_slap_sound")


func spawn_slap_sand_burst(_slap_multiplier: float = 1.0) -> void:
	# TODO: Spawn a small directional sand burst when the slap begins.
	pass


func trigger_camera_bump(amount: float = 0.08) -> void:
	# Placeholder camera feedback hook. The camera script currently supports
	# bump(), but this stays optional so the player scene can be tested alone.
	var camera := get_viewport().get_camera_3d()

	if camera != null and camera.has_method("bump"):
		camera.call("bump", amount)


func set_scenery_spawn(
	spawn_transform: Transform3D,
	scenery_safe_ground_y: float,
	scenery_safe_ground_clearance: float,
	scenery_fall_reset_height: float
) -> void:
	# Called by SceneryManager when a new playable area loads. The player keeps
	# its movement tuning, but R reset now returns to the current scenery spawn.
	reset_position = spawn_transform.origin

	var spawn_euler: Vector3 = spawn_transform.basis.get_euler()
	reset_rotation_degrees = Vector3(
		rad_to_deg(spawn_euler.x),
		rad_to_deg(spawn_euler.y),
		rad_to_deg(spawn_euler.z)
	)
	safe_ground_y = scenery_safe_ground_y
	safe_ground_clearance = scenery_safe_ground_clearance
	fall_reset_height = scenery_fall_reset_height
	water_safe_exit_position = reset_position
	_clear_water_state()
	_clear_surface_zone()


func set_default_surface(
	surface_type: String,
	surface_name: String,
	move_multiplier: float,
	linear_damping_multiplier: float,
	angular_damping_multiplier: float,
	jump_multiplier: float,
	landing_impact_multiplier: float,
	landing_sound_type: String,
	particle_type: String
) -> void:
	_default_surface_settings = _make_surface_settings(
		surface_type,
		surface_name,
		move_multiplier,
		linear_damping_multiplier,
		angular_damping_multiplier,
		jump_multiplier,
		landing_impact_multiplier,
		landing_sound_type,
		particle_type
	)

	if _surface_zone_order.is_empty():
		_apply_surface_settings(_default_surface_settings)


func enter_surface_zone(
	surface_type: String,
	surface_name: String,
	move_multiplier: float,
	linear_damping_multiplier: float,
	angular_damping_multiplier: float,
	jump_multiplier: float = 1.0,
	landing_impact_multiplier: float = 1.0,
	landing_sound_type: String = "",
	particle_type: String = "",
	source_id: int = 0
) -> void:
	var zone_id := source_id
	if zone_id == 0:
		zone_id = surface_name.hash()

	_active_surface_zones[zone_id] = _make_surface_settings(
		surface_type,
		surface_name,
		move_multiplier,
		linear_damping_multiplier,
		angular_damping_multiplier,
		jump_multiplier,
		landing_impact_multiplier,
		landing_sound_type,
		particle_type
	)
	_surface_zone_order.erase(zone_id)
	_surface_zone_order.append(zone_id)
	_select_current_surface()


func exit_surface_zone(surface_name: String, source_id: int = 0) -> void:
	if source_id != 0:
		_active_surface_zones.erase(source_id)
		_surface_zone_order.erase(source_id)
	else:
		for zone_id in _surface_zone_order.duplicate():
			var settings: Dictionary = _active_surface_zones[zone_id]
			if String(settings.get("surface_name", "")) == surface_name:
				_active_surface_zones.erase(zone_id)
				_surface_zone_order.erase(zone_id)

	_select_current_surface()


func _clear_surface_zone() -> void:
	_active_surface_zones.clear()
	_surface_zone_order.clear()
	_apply_surface_settings(_default_surface_settings)


func _select_current_surface() -> void:
	while not _surface_zone_order.is_empty():
		var zone_id: int = _surface_zone_order[_surface_zone_order.size() - 1]
		if _active_surface_zones.has(zone_id):
			var settings: Dictionary = _active_surface_zones[zone_id]
			_apply_surface_settings(settings)
			return

		_surface_zone_order.pop_back()

	_apply_surface_settings(_default_surface_settings)


func _make_surface_settings(
	surface_type: String,
	surface_name: String,
	move_multiplier: float,
	linear_damping_multiplier: float,
	angular_damping_multiplier: float,
	jump_multiplier: float,
	landing_impact_multiplier: float,
	landing_sound_type: String,
	particle_type: String
) -> Dictionary:
	var resolved_type := surface_type
	if resolved_type == "":
		resolved_type = "custom"

	var resolved_name := surface_name
	if resolved_name == "":
		resolved_name = resolved_type.capitalize()

	var resolved_landing_sound := landing_sound_type
	if resolved_landing_sound == "":
		resolved_landing_sound = _get_default_surface_sound_type(resolved_type)

	var resolved_particle := particle_type
	if resolved_particle == "":
		resolved_particle = _get_default_surface_particle_type(resolved_type)

	return {
		"surface_type": resolved_type,
		"surface_name": resolved_name,
		"move_multiplier": move_multiplier,
		"linear_damping_multiplier": linear_damping_multiplier,
		"angular_damping_multiplier": angular_damping_multiplier,
		"jump_multiplier": jump_multiplier,
		"landing_impact_multiplier": landing_impact_multiplier,
		"landing_sound_type": resolved_landing_sound,
		"particle_type": resolved_particle,
	}


func _apply_surface_settings(settings: Dictionary) -> void:
	_current_surface_type = String(settings.get("surface_type", "custom"))
	_current_surface_name = String(settings.get("surface_name", _current_surface_type))
	_surface_move_multiplier = float(settings.get("move_multiplier", 1.0))
	_surface_linear_damping_multiplier = float(settings.get("linear_damping_multiplier", 1.0))
	_surface_angular_damping_multiplier = float(settings.get("angular_damping_multiplier", 1.0))
	_surface_jump_multiplier = float(settings.get("jump_multiplier", 1.0))
	_surface_landing_impact_multiplier = float(settings.get("landing_impact_multiplier", 1.0))
	_surface_landing_sound_type = String(
		settings.get(
			"landing_sound_type",
			_get_default_surface_sound_type(_current_surface_type)
		)
	)
	_surface_particle_type = String(
		settings.get(
			"particle_type",
			_get_default_surface_particle_type(_current_surface_type)
		)
	)


func _get_default_surface_sound_type(surface_type: String) -> String:
	match surface_type:
		"sand":
			return "sand"
		"wet_tile":
			return "wet_tile"
		"dry_tile":
			return "dry_tile"
		"wood":
			return "wood"
		"water", "shallow_water":
			return "water"

	return "default"


func _get_default_surface_particle_type(surface_type: String) -> String:
	match surface_type:
		"sand":
			return "sand"
		"wet_tile", "water", "shallow_water":
			return "splash"

	return "none"


func reset_flipflop() -> void:
	var safe_reset_position := reset_position
	safe_reset_position.y = maxf(safe_reset_position.y, safe_ground_y + safe_ground_clearance)
	global_position = safe_reset_position
	global_rotation_degrees = reset_rotation_degrees
	linear_velocity = Vector3.ZERO
	angular_velocity = Vector3.ZERO
	_hop_buffer_timer = 0.0
	_flap_cooldown_timer = 0.0
	_air_flaps_remaining = max_air_flaps
	_last_jump_type = "none"
	_slap_requested = false
	_slap_cooldown_timer = 0.0
	_slap_active_timer = 0.0
	_last_slapped_object_name = "none"
	_current_slap_strength = 0.0
	_shift_slap_active = false
	_slapped_body_ids.clear()
	_recovery_cooldown_timer = 0.0
	_stuck_recovery_triggered = false
	_water_soft_reset_triggered = false
	_clear_water_state()
	_clear_surface_zone()
	_grounded_timer = 0.0
	_was_grounded = false
	_update_ground_ray_position()
	sleeping = false
