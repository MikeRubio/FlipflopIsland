extends RigidBody3D

# Shared behavior for simple 3D island props.
# Props are physics objects that can be bumped by the flipflop or nudged later.
# Each prop scene can tune its own mass, bounce, friction, and damping from the
# Inspector without needing a custom script per object type.

@export var prop_name: String = "Island Prop"
@export_enum("Custom", "Light", "Medium", "Heavy") var prop_preset: String = "Custom"
@export var debug_name: String = ""

# Heavier props need more flipflop impact to move. Lighter props scatter easily.
@export var prop_mass: float = 1.0

# Bounce controls how lively collisions feel. A beach ball wants more bounce than
# a shell or log.
@export_range(0.0, 1.0, 0.01) var bounce: float = 0.25

# Friction controls how quickly a prop stops sliding against the sand.
@export_range(0.0, 2.0, 0.01) var friction: float = 0.7

# Damping calms props down so they settle instead of spinning forever.
@export var prop_linear_damp: float = 0.7
@export var prop_angular_damp: float = 0.9

# Props that fall into the ocean or below the world are reset to where they
# started. The ocean floor is below the sand, so water_reset_height catches toys
# that slip off the island before fall_reset_height is reached.
@export var water_reset_height: float = -0.28
@export var fall_reset_height: float = -5.0
@export var use_custom_reset_position: bool = false
@export var reset_position: Vector3 = Vector3.ZERO

@export var nudge_impulse: float = 2.5

# Left click is reserved for the player slap/lunge. Keep direct prop clicking
# disabled by default so it does not mask whether slap collisions are working.
@export var click_nudge_enabled: bool = false

# Sound placeholder trigger. If a prop hits something above this speed, it asks
# the ambience audio node to play the matching sound if one is assigned.
@export var collision_sound_speed: float = 0.45
@export var collision_sound_cooldown: float = 0.35

var _start_transform: Transform3D
var _sound_cooldown_timer: float = 0.0


func _ready() -> void:
	add_to_group("resettable_prop")
	input_ray_pickable = true
	contact_monitor = true
	max_contacts_reported = 4
	_start_transform = global_transform
	_apply_prop_preset()
	mass = prop_mass
	linear_damp = prop_linear_damp
	angular_damp = prop_angular_damp

	var material: PhysicsMaterial = physics_material_override

	if material == null:
		material = PhysicsMaterial.new()
	else:
		material = material.duplicate() as PhysicsMaterial

	material.bounce = bounce
	material.friction = friction
	physics_material_override = material


func _physics_process(delta: float) -> void:
	_sound_cooldown_timer = maxf(_sound_cooldown_timer - delta, 0.0)

	if global_position.y < water_reset_height or global_position.y < fall_reset_height:
		reset_prop()

	if (
		_sound_cooldown_timer <= 0.0
		and get_contact_count() > 0
		and linear_velocity.length() >= collision_sound_speed
	):
		_play_prop_sound_hook()
		_sound_cooldown_timer = collision_sound_cooldown


func nudge(direction: Vector3) -> void:
	if direction == Vector3.ZERO:
		direction = Vector3.RIGHT

	apply_central_impulse(direction.normalized() * nudge_impulse)
	apply_torque_impulse(Vector3(
		randf_range(-nudge_impulse, nudge_impulse),
		randf_range(-nudge_impulse, nudge_impulse),
		randf_range(-nudge_impulse, nudge_impulse)
	))
	_play_prop_sound_hook()
	_sound_cooldown_timer = collision_sound_cooldown


func receive_slap_impulse(direction: Vector3, strength: float) -> void:
	# Called by the flipflop during its slap/lunge active window. This is not
	# damage; it is just an extra physics shove for toy-like prop reactions.
	if direction == Vector3.ZERO:
		direction = Vector3.RIGHT

	sleeping = false
	apply_central_impulse(direction.normalized() * strength)
	apply_torque_impulse(Vector3(
		randf_range(-strength, strength),
		randf_range(-strength, strength),
		randf_range(-strength, strength)
	) * 0.35)
	_play_prop_sound_hook()
	_sound_cooldown_timer = collision_sound_cooldown


func _input_event(
	_camera: Camera3D,
	event: InputEvent,
	event_position: Vector3,
	_normal: Vector3,
	_shape_idx: int
) -> void:
	if not click_nudge_enabled:
		return

	var mouse_event := event as InputEventMouseButton

	if mouse_event == null or not mouse_event.pressed:
		return

	nudge(global_position - event_position)


func reset_prop() -> void:
	if use_custom_reset_position:
		global_transform = Transform3D(_start_transform.basis, reset_position)
	else:
		global_transform = _start_transform

	linear_velocity = Vector3.ZERO
	angular_velocity = Vector3.ZERO
	sleeping = false


func _apply_prop_preset() -> void:
	match prop_preset:
		"Light":
			prop_mass = 0.12
			bounce = 0.14
			friction = 0.48
			prop_linear_damp = 0.72
			prop_angular_damp = 0.9
			nudge_impulse = 0.38
			collision_sound_speed = 0.3
		"Medium":
			prop_mass = 0.55
			bounce = 0.18
			friction = 0.68
			prop_linear_damp = 0.8
			prop_angular_damp = 1.05
			nudge_impulse = 0.32
			collision_sound_speed = 0.42
		"Heavy":
			prop_mass = 1.25
			bounce = 0.14
			friction = 0.78
			prop_linear_damp = 0.95
			prop_angular_damp = 1.25
			nudge_impulse = 0.22
			collision_sound_speed = 0.5


func _play_prop_sound_hook() -> void:
	var audio := get_tree().get_first_node_in_group("ambience_audio")
	if audio == null:
		return

	var lower_name := prop_name.to_lower()

	if lower_name.contains("coconut") and audio.has_method("play_coconut_bump"):
		audio.call("play_coconut_bump")
	elif lower_name.contains("shell") and audio.has_method("play_shell_scatter"):
		audio.call("play_shell_scatter")
	elif lower_name.contains("crab") and audio.has_method("play_crab_skitter"):
		audio.call("play_crab_skitter")


func get_debug_label() -> String:
	if debug_name != "":
		return debug_name

	return prop_name
