extends RigidBody2D

# Controls the lost flipflop with intentionally awkward physics.
# The flipflop is a RigidBody2D, so left/right movement and rotation use forces
# instead of directly changing position. Hopping is simulated as visual height,
# which fits this top-down island scene while still giving us landing hooks.

# Upward hop strength. Higher values make the flipflop stay airborne longer.
@export var hop_force: float = 420.0

# Sideways force from A/D or Left/Right. This should feel loose, not precise.
@export var side_force: float = 760.0

# Torque from Q/E and from flopping left/right. Higher values spin faster.
@export var torque_force: float = 1180.0

# Caps sliding speed so the flipflop stays readable on screen.
@export var max_speed: float = 520.0

# Small landing kick. This creates the bouncy slap when the flipflop hits sand.
@export_range(0.0, 1.0, 0.01) var bounce: float = 0.28

# Sand drag. Higher values stop sliding sooner; lower values make it skiddy.
@export_range(0.0, 8.0, 0.1) var friction: float = 1.15

# Where R sends the flipflop back to.
@export var reset_position: Vector2 = Vector2(0, 80)

# Pulls the visual hop back down to the sand.
@export var hop_gravity: float = 980.0

# Random-looking air wobble so the flipflop never feels perfectly stable.
@export var air_wobble_torque: float = 90.0

# Landing hooks only fire when the downward slap is strong enough.
@export var landing_slap_threshold: float = 160.0

@onready var _body_sprite: Polygon2D = $Body
@onready var _strap_sprite: Line2D = $Strap
@onready var _shadow_sprite: Polygon2D = $SoleShadow

var _hop_height: float = 0.0
var _hop_velocity: float = 0.0
var _was_airborne: bool = false
var _space_was_pressed: bool = false
var _reset_was_pressed: bool = false


func _ready() -> void:
	linear_damp = friction


func _physics_process(delta: float) -> void:
	linear_damp = friction

	var side_input := _get_side_input()
	var spin_input := _get_spin_input()

	if side_input != 0.0:
		_apply_flop_sideways(side_input)

	if spin_input != 0.0:
		apply_torque(spin_input * torque_force)

	if _was_just_pressed(KEY_SPACE, _space_was_pressed):
		_try_hop()

	if _was_just_pressed(KEY_R, _reset_was_pressed):
		reset_flipflop()

	_update_hop(delta)
	_apply_air_wobble(delta)
	_limit_speed()


func _get_side_input() -> float:
	var input := 0.0

	if Input.is_key_pressed(KEY_A) or Input.is_key_pressed(KEY_LEFT):
		input -= 1.0

	if Input.is_key_pressed(KEY_D) or Input.is_key_pressed(KEY_RIGHT):
		input += 1.0

	return input


func _get_spin_input() -> float:
	var input := 0.0

	if Input.is_key_pressed(KEY_Q):
		input -= 1.0

	if Input.is_key_pressed(KEY_E):
		input += 1.0

	return input


func _was_just_pressed(key: Key, was_pressed: bool) -> bool:
	var is_pressed := Input.is_key_pressed(key)
	var just_pressed := is_pressed and not was_pressed

	if key == KEY_SPACE:
		_space_was_pressed = is_pressed
	elif key == KEY_R:
		_reset_was_pressed = is_pressed

	return just_pressed


func _apply_flop_sideways(direction: float) -> void:
	apply_central_force(Vector2.RIGHT * direction * side_force)

	# Side input also twists the sandal, making movement awkward and funny.
	apply_torque(direction * torque_force * 0.65)


func _try_hop() -> void:
	if _hop_height > 0.0:
		return

	_hop_velocity = hop_force
	_was_airborne = true

	# A hop starts with a little spin so the flipflop rotates in the air.
	apply_torque_impulse(randf_range(-torque_force, torque_force) * 0.08)


func _update_hop(delta: float) -> void:
	if _hop_height <= 0.0 and _hop_velocity <= 0.0:
		_update_visual_height()
		return

	_hop_height += _hop_velocity * delta
	_hop_velocity -= hop_gravity * delta

	if _hop_height <= 0.0:
		var impact_speed := absf(_hop_velocity)

		_hop_height = 0.0
		_hop_velocity = 0.0

		if _was_airborne:
			_on_landed(impact_speed)

		_was_airborne = false

	_update_visual_height()


func _apply_air_wobble(delta: float) -> void:
	if _hop_height <= 0.0:
		return

	apply_torque(randf_range(-air_wobble_torque, air_wobble_torque) * delta)


func _limit_speed() -> void:
	if linear_velocity.length() > max_speed:
		linear_velocity = linear_velocity.normalized() * max_speed


func _update_visual_height() -> void:
	var visual_offset := Vector2(0.0, -_hop_height)
	_body_sprite.position = visual_offset
	_strap_sprite.position = visual_offset

	var shadow_scale := clampf(1.0 - (_hop_height / 260.0), 0.55, 1.0)
	_shadow_sprite.scale = Vector2(shadow_scale, shadow_scale)


func _on_landed(impact_speed: float) -> void:
	# This is the landing detection hook. Add real sound, particles, camera shake,
	# or animation here later without changing the controller flow.
	if impact_speed >= landing_slap_threshold:
		play_slap_sound()
		spawn_sand_particles()

		var bounce_direction := Vector2.RIGHT.rotated(rotation)
		apply_central_impulse(bounce_direction * bounce * impact_speed)
		apply_torque_impulse(randf_range(-1.0, 1.0) * bounce * impact_speed * 0.65)


func play_slap_sound() -> void:
	# Placeholder for an AudioStreamPlayer2D slap sound.
	pass


func spawn_sand_particles() -> void:
	# Placeholder for a small sand puff particle effect.
	pass


func reset_flipflop() -> void:
	global_position = reset_position
	rotation = 0.0
	linear_velocity = Vector2.ZERO
	angular_velocity = 0.0
	_hop_height = 0.0
	_hop_velocity = 0.0
	_was_airborne = false
	_update_visual_height()
