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

# Space hop impulse while touching the sand. Keep this modest: the flipflop
# should hop, not launch like a platformer character.
@export var grounded_jump_impulse: float = 0.32

# Small camera-relative shove added to a normal hop when WASD is held.
@export var jump_forward_assist: float = 0.085

# Backward-compatible mirror for older scenes/debug text that still look for
# "hop_impulse". Presets keep it synced with grounded_jump_impulse.
@export var hop_impulse: float = 0.32

# Air flop tuning. The default gives one awkward second jump while airborne.
# It uses impulse and torque, so it still feels like a loose physical object.
@export var max_air_flops: int = 1
@export var air_flop_impulse: float = 0.22
@export var air_flop_forward_assist: float = 0.1
@export var air_flop_torque: float = 0.045
@export var air_flop_cooldown: float = 0.58

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

# Left click slap/lunge. This is a sudden sandal flop, not a combat attack.
# The player gets a central impulse in the camera-facing direction and touched
# physics props get an extra shove during the short active window.
@export var slap_impulse: float = 0.36
@export var slap_upward_impulse: float = 0.065
@export var slap_torque: float = 0.045
@export var slap_cooldown: float = 0.62
@export var slap_active_duration: float = 0.2
@export var slap_prop_force_multiplier: float = 2.4
@export var slap_shift_multiplier: float = 1.32
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

# Ground detection uses a world-down raycast, so it still works when the
# flipflop lands sideways or upside down.
@export var ground_check_distance: float = 0.44
@export var grounded_grace_time: float = 0.12
@export var hop_input_buffer_time: float = 0.14

# Prevents repeated Space presses from stacking hop impulses.
@export var hop_cooldown_time: float = 0.45

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

# Temporary movement debug. Leave off during normal play.
@export var debug_movement: bool = false
@export var debug_print_interval: float = 0.35

@onready var _ground_ray: RayCast3D = $GroundRay
@onready var _sole_mesh: MeshInstance3D = $Sole

const MOVEMENT_PRESETS := {
	"Gentle": {
		"move_force": 1.65,
		"move_impulse": 0.0025,
		"grounded_jump_impulse": 0.26,
		"jump_forward_assist": 0.05,
		"max_air_flops": 1,
		"air_flop_impulse": 0.16,
		"air_flop_forward_assist": 0.06,
		"air_flop_torque": 0.018,
		"air_flop_cooldown": 0.7,
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
		"slap_impulse": 0.22,
		"slap_upward_impulse": 0.04,
		"slap_torque": 0.018,
		"slap_cooldown": 0.78,
		"slap_active_duration": 0.16,
		"slap_prop_force_multiplier": 1.6,
		"slap_shift_multiplier": 1.15,
		"slap_camera_bump": 0.04,
		"slap_particle_enabled": true,
		"linear_damping": 0.9,
		"angular_damping": 4.4,
		"max_linear_speed": 3.0,
		"max_angular_speed": 3.4,
		"air_control_multiplier": 0.13,
		"ground_control_multiplier": 0.95,
	},
	"Playable Physics": {
		"move_force": 2.25,
		"move_impulse": 0.0045,
		"grounded_jump_impulse": 0.32,
		"jump_forward_assist": 0.085,
		"max_air_flops": 1,
		"air_flop_impulse": 0.22,
		"air_flop_forward_assist": 0.1,
		"air_flop_torque": 0.045,
		"air_flop_cooldown": 0.58,
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
		"slap_impulse": 0.36,
		"slap_upward_impulse": 0.065,
		"slap_torque": 0.045,
		"slap_cooldown": 0.62,
		"slap_active_duration": 0.2,
		"slap_prop_force_multiplier": 2.4,
		"slap_shift_multiplier": 1.32,
		"slap_camera_bump": 0.065,
		"slap_particle_enabled": true,
		"linear_damping": 0.62,
		"angular_damping": 3.5,
		"max_linear_speed": 3.9,
		"max_angular_speed": 4.5,
		"air_control_multiplier": 0.11,
		"ground_control_multiplier": 1.0,
	},
	"Chaotic": {
		"move_force": 3.35,
		"move_impulse": 0.009,
		"grounded_jump_impulse": 0.4,
		"jump_forward_assist": 0.13,
		"max_air_flops": 1,
		"air_flop_impulse": 0.3,
		"air_flop_forward_assist": 0.16,
		"air_flop_torque": 0.09,
		"air_flop_cooldown": 0.48,
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
		"slap_impulse": 0.52,
		"slap_upward_impulse": 0.09,
		"slap_torque": 0.095,
		"slap_cooldown": 0.46,
		"slap_active_duration": 0.24,
		"slap_prop_force_multiplier": 3.3,
		"slap_shift_multiplier": 1.55,
		"slap_camera_bump": 0.1,
		"slap_particle_enabled": true,
		"linear_damping": 0.45,
		"angular_damping": 2.3,
		"max_linear_speed": 5.4,
		"max_angular_speed": 6.3,
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
var _hop_cooldown_timer: float = 0.0
var _speed_clamped: bool = false
var _angular_speed_clamped: bool = false
var _debug_timer: float = 0.0
var _raw_move_input: Vector2 = Vector2.ZERO
var _last_input_direction: Vector3 = Vector3.ZERO
var _last_camera_forward: Vector3 = Vector3.FORWARD
var _last_camera_right: Vector3 = Vector3.RIGHT
var _last_move_force_applied: Vector3 = Vector3.ZERO
var _recovery_cooldown_timer: float = 0.0
var _stuck_recovery_triggered: bool = false
var _flipflop_color_index: int = 0
var _air_flops_remaining: int = 1
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
var _slapped_body_ids: Dictionary = {}
var _sole_material: StandardMaterial3D


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
	_air_flops_remaining = max_air_flops


func _physics_process(delta: float) -> void:
	linear_damp = linear_damping
	angular_damp = angular_damping
	_update_ground_ray_position()
	_hop_cooldown_timer = maxf(_hop_cooldown_timer - delta, 0.0)
	_slap_cooldown_timer = maxf(_slap_cooldown_timer - delta, 0.0)
	_slap_active_timer = maxf(_slap_active_timer - delta, 0.0)
	_recovery_cooldown_timer = maxf(_recovery_cooldown_timer - delta, 0.0)
	_stuck_recovery_triggered = false

	var grounded := _update_grounded_state(delta)
	if _touching_ground:
		_air_flops_remaining = max_air_flops

	_boost_active = _is_boost_pressed()
	_current_move_multiplier = _get_current_move_multiplier()
	_current_max_linear_speed = _get_current_max_linear_speed()
	_current_max_angular_speed = _get_current_max_angular_speed()

	var control_multiplier := ground_control_multiplier if grounded else air_control_multiplier
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
	_apply_twist_controls(control_multiplier)
	_process_slap_request(forward_axis)

	if _was_just_pressed(KEY_SPACE, _space_was_pressed):
		_hop_buffer_timer = hop_input_buffer_time
	else:
		_hop_buffer_timer = maxf(_hop_buffer_timer - delta, 0.0)

	if _hop_buffer_timer > 0.0 and _hop_cooldown_timer <= 0.0:
		if grounded:
			_grounded_hop(move_input, forward_axis, right_axis)
			_hop_buffer_timer = 0.0
			_hop_cooldown_timer = hop_cooldown_time
		elif _air_flops_remaining > 0:
			_air_flop(move_input, forward_axis, right_axis)
			_hop_buffer_timer = 0.0
			_hop_cooldown_timer = air_flop_cooldown

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
	_clamp_velocity()
	_print_debug_if_enabled(delta, grounded)

	_was_grounded = grounded
	_last_vertical_velocity = linear_velocity.y


func _get_camera_axes() -> Dictionary:
	var camera := get_viewport().get_camera_3d()

	if camera != null:
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
	_current_slap_strength = slap_impulse * slap_multiplier
	_last_slap_direction = slap_direction
	_last_slapped_object_name = "none"
	_slapped_body_ids.clear()
	sleeping = false

	# Central impulse gives a readable lunge without using offset forces that
	# would make the flipflop wheel-spin uncontrollably.
	apply_central_impulse(slap_direction * _current_slap_strength)
	apply_central_impulse(Vector3.UP * slap_upward_impulse * slap_multiplier)
	apply_torque_impulse(Vector3(
		randf_range(-slap_torque, slap_torque),
		randf_range(-slap_torque * 0.5, slap_torque * 0.5),
		randf_range(-slap_torque, slap_torque)
	) * slap_multiplier)

	_slap_active_timer = slap_active_duration
	_slap_cooldown_timer = slap_cooldown
	play_slap_attack_sound(slap_multiplier)

	if slap_particle_enabled:
		spawn_slap_sand_burst(slap_multiplier)

	trigger_camera_bump(slap_camera_bump * slap_multiplier)


func _grounded_hop(move_input: Vector2, forward_axis: Vector3, right_axis: Vector3) -> void:
	# Trim downward speed before hopping so Space feels responsive near the sand
	# without letting the flipflop stack huge upward launches.
	if linear_velocity.y < 0.0:
		var velocity := linear_velocity
		velocity.y *= 0.2
		linear_velocity = velocity

	sleeping = false
	apply_central_impulse(Vector3.UP * grounded_jump_impulse)

	var move_direction := _get_camera_relative_move_direction(move_input, forward_axis, right_axis)
	if move_direction != Vector3.ZERO and jump_forward_assist > 0.0:
		apply_central_impulse(
			move_direction
			* jump_forward_assist
			* _get_current_hop_assist_multiplier()
		)

	# Add a tiny random tumble so hops land differently without becoming wild.
	apply_torque_impulse(Vector3(
		randf_range(-torque_strength, torque_strength),
		randf_range(-torque_strength, torque_strength),
		randf_range(-torque_strength, torque_strength)
	) * 1.4)
	_grounded_timer = 0.0
	_last_jump_type = "grounded_hop"


func _air_flop(move_input: Vector2, forward_axis: Vector3, right_axis: Vector3) -> void:
	if _air_flops_remaining <= 0:
		return

	_air_flops_remaining -= 1
	sleeping = false

	# Soften falling speed before the air flop. This gives the second jump a
	# readable lift without allowing Space spam to build huge upward velocity.
	if linear_velocity.y < 0.0:
		var velocity := linear_velocity
		velocity.y *= 0.35
		linear_velocity = velocity

	apply_central_impulse(Vector3.UP * air_flop_impulse)

	var move_direction := _get_camera_relative_move_direction(move_input, forward_axis, right_axis)
	if move_direction != Vector3.ZERO and air_flop_forward_assist > 0.0:
		apply_central_impulse(
			move_direction
			* air_flop_forward_assist
			* _get_current_hop_assist_multiplier()
		)

	# The air flop is intentionally messy: a small random torque sells the
	# "loose sandal flailing in the air" feeling without driving movement.
	apply_torque_impulse(Vector3(
		randf_range(-air_flop_torque, air_flop_torque),
		randf_range(-air_flop_torque * 0.75, air_flop_torque * 0.75),
		randf_range(-air_flop_torque, air_flop_torque)
	))
	_last_jump_type = "air_flop"


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
	if _boost_active:
		return slap_shift_multiplier

	return 1.0


func _get_current_max_linear_speed() -> float:
	if _boost_active:
		return boost_max_linear_speed

	return max_linear_speed


func _get_current_max_angular_speed() -> float:
	if _boost_active:
		return boost_max_angular_speed

	return max_angular_speed


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
	_air_flops_remaining = max_air_flops
	_slap_requested = false
	_slap_active_timer = 0.0
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
		" hop_cooldown=",
		snappedf(_hop_cooldown_timer, 0.01),
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
		" air_flops=",
		_air_flops_remaining,
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
		_angular_speed_clamped
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
	grounded_jump_impulse = float(preset["grounded_jump_impulse"])
	jump_forward_assist = float(preset["jump_forward_assist"])
	hop_impulse = grounded_jump_impulse
	max_air_flops = int(preset["max_air_flops"])
	air_flop_impulse = float(preset["air_flop_impulse"])
	air_flop_forward_assist = float(preset["air_flop_forward_assist"])
	air_flop_torque = float(preset["air_flop_torque"])
	air_flop_cooldown = float(preset["air_flop_cooldown"])
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
	slap_impulse = float(preset["slap_impulse"])
	slap_upward_impulse = float(preset["slap_upward_impulse"])
	slap_torque = float(preset["slap_torque"])
	slap_cooldown = float(preset["slap_cooldown"])
	slap_active_duration = float(preset["slap_active_duration"])
	slap_prop_force_multiplier = float(preset["slap_prop_force_multiplier"])
	slap_shift_multiplier = float(preset["slap_shift_multiplier"])
	slap_camera_bump = float(preset["slap_camera_bump"])
	slap_particle_enabled = bool(preset["slap_particle_enabled"])
	linear_damping = float(preset["linear_damping"])
	angular_damping = float(preset["angular_damping"])
	max_linear_speed = float(preset["max_linear_speed"])
	max_angular_speed = float(preset["max_angular_speed"])
	air_control_multiplier = float(preset["air_control_multiplier"])
	ground_control_multiplier = float(preset["ground_control_multiplier"])

	if _touching_ground or _grounded_timer > 0.0:
		_air_flops_remaining = max_air_flops
	else:
		_air_flops_remaining = mini(_air_flops_remaining, max_air_flops)


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
		"hop_cooldown": _hop_cooldown_timer,
		"jump_cooldown": _hop_cooldown_timer,
		"air_flops_remaining": _air_flops_remaining,
		"max_air_flops": max_air_flops,
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
		"last_slapped_object_name": _last_slapped_object_name,
		"current_slap_strength": _current_slap_strength,
		"move_impulse": move_impulse,
		"move_force": move_force,
		"hop_impulse": hop_impulse,
		"grounded_jump_impulse": grounded_jump_impulse,
		"jump_forward_assist": jump_forward_assist,
		"air_flop_impulse": air_flop_impulse,
		"air_flop_forward_assist": air_flop_forward_assist,
		"air_flop_torque": air_flop_torque,
		"air_flop_cooldown": air_flop_cooldown,
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
		"slap_impulse": slap_impulse,
		"slap_upward_impulse": slap_upward_impulse,
		"slap_torque": slap_torque,
		"slap_cooldown_time": slap_cooldown,
		"slap_active_duration": slap_active_duration,
		"slap_prop_force_multiplier": slap_prop_force_multiplier,
		"slap_shift_multiplier": slap_shift_multiplier,
		"slap_camera_bump": slap_camera_bump,
		"slap_particle_enabled": slap_particle_enabled,
		"linear_damping": linear_damping,
		"angular_damping": angular_damping,
		"max_linear_speed": max_linear_speed,
		"max_angular_speed": max_angular_speed,
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
	if impact_speed < landing_slap_threshold:
		return

	# Hard landing hook. These functions are placeholders for real feedback.
	var slap_multiplier := _get_current_slap_multiplier()
	play_slap_sound(slap_multiplier)
	spawn_sand_particles(slap_multiplier)

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


func spawn_sand_particles(_slap_multiplier: float = 1.0) -> void:
	# TODO: Spawn a small sand puff GPUParticles3D effect.
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


func reset_flipflop() -> void:
	var safe_reset_position := reset_position
	safe_reset_position.y = maxf(safe_reset_position.y, safe_ground_y + safe_ground_clearance)
	global_position = safe_reset_position
	global_rotation_degrees = reset_rotation_degrees
	linear_velocity = Vector3.ZERO
	angular_velocity = Vector3.ZERO
	_hop_buffer_timer = 0.0
	_hop_cooldown_timer = 0.0
	_air_flops_remaining = max_air_flops
	_last_jump_type = "none"
	_slap_requested = false
	_slap_cooldown_timer = 0.0
	_slap_active_timer = 0.0
	_last_slapped_object_name = "none"
	_current_slap_strength = 0.0
	_slapped_body_ids.clear()
	_recovery_cooldown_timer = 0.0
	_stuck_recovery_triggered = false
	_grounded_timer = 0.0
	_was_grounded = false
	_update_ground_ray_position()
	sleeping = false
