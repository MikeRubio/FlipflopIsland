extends RigidBody3D

# Physics controller for the lost flipflop.
# This is deliberately not a humanoid controller: WASD gives the RigidBody3D
# small impulses in camera-relative directions, then torque makes it flop, roll,
# and tumble. The result should be readable, but still awkward and physical.

# Movement shove applied while WASD is held.
# Higher values explore faster, but too high makes the flipflop feel like a car.
@export var move_impulse: float = 0.026

# Space hop impulse. Keep this modest: the flipflop should hop, not launch.
@export var hop_impulse: float = 0.34

# Shared torque strength for flopping, rolling, and twisting.
# Lower values make controls calmer. Higher values create more tumbling.
@export var torque_strength: float = 0.018

# Air control is intentionally weaker so airborne movement feels clumsy.
@export var air_control_multiplier: float = 0.12

# Ground control is stronger because the flipflop can push against the sand.
@export var ground_control_multiplier: float = 1.0

# Damping values calm the physics down over time.
# Lower linear damping means more sliding. Higher angular damping means less
# endless spinning.
@export var linear_damping: float = 0.85
@export var angular_damping: float = 3.2

# Safety clamps. These keep tumbling funny without becoming impossible to test.
@export var max_linear_speed: float = 4.2
@export var max_angular_speed: float = 4.8

# Ground detection uses a world-down raycast, so it still works when the
# flipflop lands sideways or upside down.
@export var ground_check_distance: float = 0.42
@export var grounded_grace_time: float = 0.12
@export var hop_input_buffer_time: float = 0.14

# Prevents repeated Space presses from stacking hop impulses.
@export var hop_cooldown_time: float = 0.45

# Holding Space while grounded gives a small recovery torque if the flipflop is
# upside down or badly tilted. It is not automatic, so funny physics remain.
@export var upside_down_help_strength: float = 0.45

# Hard landings call the placeholder feedback functions below.
@export var landing_slap_threshold: float = 3.0

# Reset tuning.
@export var reset_position: Vector3 = Vector3(0.0, 0.35, 0.0)
@export var fall_reset_height: float = -8.0

# Temporary movement debug. Leave off during normal play.
@export var debug_movement: bool = false
@export var debug_print_interval: float = 0.35

@onready var _ground_ray: RayCast3D = $GroundRay

const MOVEMENT_PRESETS := {
	"Gentle": {
		"move_impulse": 0.018,
		"hop_impulse": 0.24,
		"torque_strength": 0.012,
		"linear_damping": 1.05,
		"angular_damping": 3.8,
		"max_linear_speed": 3.2,
		"max_angular_speed": 3.8,
		"air_control_multiplier": 0.08,
		"ground_control_multiplier": 0.9,
	},
	"Normal": {
		"move_impulse": 0.026,
		"hop_impulse": 0.34,
		"torque_strength": 0.018,
		"linear_damping": 0.85,
		"angular_damping": 3.2,
		"max_linear_speed": 4.2,
		"max_angular_speed": 4.8,
		"air_control_multiplier": 0.12,
		"ground_control_multiplier": 1.0,
	},
	"Chaotic": {
		"move_impulse": 0.045,
		"hop_impulse": 0.52,
		"torque_strength": 0.04,
		"linear_damping": 0.5,
		"angular_damping": 1.7,
		"max_linear_speed": 6.2,
		"max_angular_speed": 7.5,
		"air_control_multiplier": 0.2,
		"ground_control_multiplier": 1.15,
	},
}

const PRESET_ORDER := ["Gentle", "Normal", "Chaotic"]

var current_preset_name: String = "Normal"
var _was_grounded: bool = false
var _grounded_timer: float = 0.0
var _last_vertical_velocity: float = 0.0
var _space_was_pressed: bool = false
var _reset_was_pressed: bool = false
var _hop_buffer_timer: float = 0.0
var _hop_cooldown_timer: float = 0.0
var _speed_clamped: bool = false
var _angular_speed_clamped: bool = false
var _debug_timer: float = 0.0


func _ready() -> void:
	apply_movement_preset(current_preset_name)
	linear_damp = linear_damping
	angular_damp = angular_damping
	_ground_ray.top_level = true
	_update_ground_ray_position()
	_was_grounded = _is_close_to_ground()


func _physics_process(delta: float) -> void:
	linear_damp = linear_damping
	angular_damp = angular_damping
	_update_ground_ray_position()
	_hop_cooldown_timer = maxf(_hop_cooldown_timer - delta, 0.0)

	var grounded := _update_grounded_state(delta)
	var control_multiplier := ground_control_multiplier if grounded else air_control_multiplier
	var camera_axes := _get_camera_axes()
	var forward_axis: Vector3 = camera_axes["forward"]
	var right_axis: Vector3 = camera_axes["right"]
	var move_input := _get_move_input()

	_apply_camera_relative_movement(
		move_input,
		forward_axis,
		right_axis,
		control_multiplier
	)
	_apply_twist_controls(control_multiplier)

	if _was_just_pressed(KEY_SPACE, _space_was_pressed):
		_hop_buffer_timer = hop_input_buffer_time
	else:
		_hop_buffer_timer = maxf(_hop_buffer_timer - delta, 0.0)

	if _hop_buffer_timer > 0.0 and grounded and _hop_cooldown_timer <= 0.0:
		_hop()
		_hop_buffer_timer = 0.0
		_hop_cooldown_timer = hop_cooldown_time

	if Input.is_key_pressed(KEY_SPACE) and grounded:
		_apply_upside_down_help(delta)

	if _was_just_pressed(KEY_R, _reset_was_pressed):
		reset_flipflop()

	if not _was_grounded and grounded:
		_on_landed(absf(_last_vertical_velocity))

	if global_position.y < fall_reset_height:
		reset_flipflop()

	_clamp_velocity()
	_print_debug_if_enabled(delta, grounded)

	_was_grounded = grounded
	_last_vertical_velocity = linear_velocity.y


func _get_camera_axes() -> Dictionary:
	var camera := get_viewport().get_camera_3d()

	if camera != null:
		var camera_forward := -camera.global_transform.basis.z
		camera_forward.y = 0.0
		camera_forward = camera_forward.normalized()

		var camera_right := camera.global_transform.basis.x
		camera_right.y = 0.0
		camera_right = camera_right.normalized()

		if camera_forward != Vector3.ZERO and camera_right != Vector3.ZERO:
			return {
				"forward": camera_forward,
				"right": camera_right,
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
	control_multiplier: float
) -> void:
	if move_input == Vector2.ZERO:
		return

	var move_direction := (
		forward_axis * move_input.y
		+ right_axis * move_input.x
	).normalized()

	# The impulse is what makes WASD understandable from the camera view.
	apply_central_impulse(move_direction * move_impulse * control_multiplier)

	# The torque is what keeps it from feeling like a normal character.
	# Forward/back input pitches the sandal. Left/right input rolls it.
	var pitch_axis := right_axis
	var roll_axis := forward_axis
	var torque := (
		pitch_axis * move_input.y
		+ roll_axis * -move_input.x
	) * torque_strength * control_multiplier

	apply_torque_impulse(torque)


func _apply_twist_controls(control_multiplier: float) -> void:
	var input := 0.0

	if Input.is_key_pressed(KEY_Q):
		input += 1.0

	if Input.is_key_pressed(KEY_E):
		input -= 1.0

	if input == 0.0:
		return

	apply_torque_impulse(Vector3.UP * input * torque_strength * control_multiplier)


func _hop() -> void:
	# Trim downward speed before hopping so Space feels responsive near the sand
	# without letting the flipflop stack huge upward launches.
	if linear_velocity.y < 0.0:
		var velocity := linear_velocity
		velocity.y *= 0.2
		linear_velocity = velocity

	apply_central_impulse(Vector3.UP * hop_impulse)

	# Add a tiny random tumble so hops land differently without becoming wild.
	apply_torque_impulse(Vector3(
		randf_range(-torque_strength, torque_strength),
		randf_range(-torque_strength, torque_strength),
		randf_range(-torque_strength, torque_strength)
	) * 1.4)


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
	if _is_close_to_ground():
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

	return just_pressed


func _clamp_velocity() -> void:
	_speed_clamped = false
	_angular_speed_clamped = false

	if linear_velocity.length() > max_linear_speed:
		linear_velocity = linear_velocity.normalized() * max_linear_speed
		_speed_clamped = true

	if angular_velocity.length() > max_angular_speed:
		angular_velocity = angular_velocity.normalized() * max_angular_speed
		_angular_speed_clamped = true


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
		" hop_cooldown=",
		snappedf(_hop_cooldown_timer, 0.01),
		" speed_clamped=",
		_speed_clamped,
		" angular_clamped=",
		_angular_speed_clamped
	)


func apply_movement_preset(preset_name: String) -> void:
	if not MOVEMENT_PRESETS.has(preset_name):
		return

	var preset: Dictionary = MOVEMENT_PRESETS[preset_name]
	current_preset_name = preset_name
	move_impulse = preset["move_impulse"]
	hop_impulse = preset["hop_impulse"]
	torque_strength = preset["torque_strength"]
	linear_damping = preset["linear_damping"]
	angular_damping = preset["angular_damping"]
	max_linear_speed = preset["max_linear_speed"]
	max_angular_speed = preset["max_angular_speed"]
	air_control_multiplier = preset["air_control_multiplier"]
	ground_control_multiplier = preset["ground_control_multiplier"]


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
		"linear_speed": linear_velocity.length(),
		"angular_speed": angular_velocity.length(),
		"grounded": _grounded_timer > 0.0,
		"hop_cooldown": _hop_cooldown_timer,
		"move_impulse": move_impulse,
		"hop_impulse": hop_impulse,
		"torque_strength": torque_strength,
		"linear_damping": linear_damping,
		"angular_damping": angular_damping,
		"max_linear_speed": max_linear_speed,
		"max_angular_speed": max_angular_speed,
	}


func _on_landed(impact_speed: float) -> void:
	if impact_speed < landing_slap_threshold:
		return

	# Hard landing hook. These functions are placeholders for real feedback.
	play_slap_sound()
	spawn_sand_particles()
	trigger_camera_bump()

	# TODO: Add a water splash if the landing point is in shallow water.
	# TODO: Add extra wave push feedback when surf hits the flipflop.


func play_slap_sound() -> void:
	# TODO: Trigger an AudioStreamPlayer3D slap sound.
	pass


func spawn_sand_particles() -> void:
	# TODO: Spawn a small sand puff GPUParticles3D effect.
	pass


func trigger_camera_bump() -> void:
	# Placeholder camera feedback hook. The camera script currently supports
	# bump(), but this stays optional so the player scene can be tested alone.
	var camera := get_viewport().get_camera_3d()

	if camera != null and camera.has_method("bump"):
		camera.call("bump")


func reset_flipflop() -> void:
	global_position = reset_position
	global_rotation = Vector3.ZERO
	linear_velocity = Vector3.ZERO
	angular_velocity = Vector3.ZERO
	_hop_buffer_timer = 0.0
	_hop_cooldown_timer = 0.0
	_grounded_timer = 0.0
	_was_grounded = false
	_update_ground_ray_position()
	sleeping = false
