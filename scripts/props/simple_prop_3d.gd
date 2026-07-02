extends RigidBody3D

# Shared behavior for simple 3D scenery props.
# Props are physics objects that can be bumped by the flipflop or nudged later.
# Each prop scene can tune its own mass, bounce, friction, and damping from the
# Inspector without needing a custom script per object type.

@export var prop_name: String = "Island Prop"
@export_enum("Custom", "Light", "Medium", "Heavy") var prop_preset: String = "Custom"
@export_enum("custom", "light", "medium", "heavy", "bouncy", "slippery") var prop_category: String = "custom"
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
@export var reset_rotation_to_start: bool = true

@export var nudge_impulse: float = 2.5
@export var slap_response_multiplier: float = 1.0

# Left click is reserved for the player slap/lunge. Keep direct prop clicking
# disabled by default so it does not mask whether slap collisions are working.
@export var click_nudge_enabled: bool = false

# Sound placeholder trigger. If a prop hits something above this speed, it asks
# the ambience audio node to play the matching sound if one is assigned.
@export var collision_sound_speed: float = 0.45
@export var collision_sound_cooldown: float = 0.35
@export var collision_sound_key: String = ""

var _start_transform: Transform3D
var _sound_cooldown_timer: float = 0.0
var _resolved_category: String = "custom"


func _ready() -> void:
	add_to_group("resettable_prop")
	input_ray_pickable = true
	contact_monitor = true
	max_contacts_reported = 4
	_start_transform = global_transform
	_apply_prop_tuning()
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

	var adjusted_strength: float = strength * slap_response_multiplier

	sleeping = false
	apply_central_impulse(direction.normalized() * adjusted_strength)
	apply_torque_impulse(Vector3(
		randf_range(-adjusted_strength, adjusted_strength),
		randf_range(-adjusted_strength, adjusted_strength),
		randf_range(-adjusted_strength, adjusted_strength)
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
		var reset_basis: Basis = _start_transform.basis if reset_rotation_to_start else global_transform.basis
		global_transform = Transform3D(reset_basis, reset_position)
	else:
		if reset_rotation_to_start:
			global_transform = _start_transform
		else:
			global_position = _start_transform.origin

	linear_velocity = Vector3.ZERO
	angular_velocity = Vector3.ZERO
	sleeping = false


func _apply_prop_tuning() -> void:
	_resolved_category = _resolve_prop_category()

	if _resolved_category != "custom":
		_apply_prop_category(_resolved_category)
		return

	_apply_prop_preset()


func _resolve_prop_category() -> String:
	if prop_category != "custom":
		return prop_category

	match prop_preset:
		"Light":
			return "light"
		"Medium":
			return "medium"
		"Heavy":
			return "heavy"

	return "custom"


func _apply_prop_category(category: String) -> void:
	match category:
		"light":
			prop_mass = 0.12
			bounce = 0.16
			friction = 0.46
			prop_linear_damp = 0.68
			prop_angular_damp = 0.86
			nudge_impulse = 0.42
			slap_response_multiplier = 1.35
			collision_sound_speed = 0.28
		"medium":
			prop_mass = 0.55
			bounce = 0.18
			friction = 0.66
			prop_linear_damp = 0.8
			prop_angular_damp = 1.05
			nudge_impulse = 0.34
			slap_response_multiplier = 1.0
			collision_sound_speed = 0.42
		"heavy":
			prop_mass = 1.35
			bounce = 0.12
			friction = 0.8
			prop_linear_damp = 0.98
			prop_angular_damp = 1.3
			nudge_impulse = 0.24
			slap_response_multiplier = 0.65
			collision_sound_speed = 0.5
		"bouncy":
			prop_mass = 0.18
			bounce = 0.78
			friction = 0.24
			prop_linear_damp = 0.28
			prop_angular_damp = 0.38
			nudge_impulse = 0.82
			slap_response_multiplier = 1.15
			collision_sound_speed = 0.35
		"slippery":
			prop_mass = 0.18
			bounce = 0.1
			friction = 0.18
			prop_linear_damp = 0.42
			prop_angular_damp = 0.68
			nudge_impulse = 0.42
			slap_response_multiplier = 1.25
			collision_sound_speed = 0.28


func _apply_prop_preset() -> void:
	match prop_preset:
		"Light":
			prop_mass = 0.12
			bounce = 0.14
			friction = 0.48
			prop_linear_damp = 0.72
			prop_angular_damp = 0.9
			nudge_impulse = 0.38
			slap_response_multiplier = 1.25
			collision_sound_speed = 0.3
		"Medium":
			prop_mass = 0.55
			bounce = 0.18
			friction = 0.68
			prop_linear_damp = 0.8
			prop_angular_damp = 1.05
			nudge_impulse = 0.32
			slap_response_multiplier = 1.0
			collision_sound_speed = 0.42
		"Heavy":
			prop_mass = 1.25
			bounce = 0.14
			friction = 0.78
			prop_linear_damp = 0.95
			prop_angular_damp = 1.25
			nudge_impulse = 0.22
			slap_response_multiplier = 0.7
			collision_sound_speed = 0.5


func _play_prop_sound_hook() -> void:
	var audio: Node = get_tree().get_first_node_in_group("ambience_audio")
	if audio == null:
		return

	if _play_named_sound_hook(audio):
		return

	var lower_name := prop_name.to_lower()

	if lower_name.contains("coconut") and audio.has_method("play_coconut_bump"):
		audio.call("play_coconut_bump")
	elif lower_name.contains("shell") and audio.has_method("play_shell_scatter"):
		audio.call("play_shell_scatter")
	elif lower_name.contains("crab") and audio.has_method("play_crab_skitter"):
		audio.call("play_crab_skitter")


func _play_named_sound_hook(audio: Node) -> bool:
	if collision_sound_key == "":
		return false

	match collision_sound_key:
		"coconut":
			if audio.has_method("play_coconut_bump"):
				audio.call("play_coconut_bump")
				return true
		"shell":
			if audio.has_method("play_shell_scatter"):
				audio.call("play_shell_scatter")
				return true
		"crab":
			if audio.has_method("play_crab_skitter"):
				audio.call("play_crab_skitter")
				return true
		"slap":
			if audio.has_method("play_slap_sound"):
				audio.call("play_slap_sound")
				return true
		"pool_splash":
			if audio.has_method("play_pool_splash"):
				audio.call("play_pool_splash")
				return true

	return false


func get_debug_label() -> String:
	if debug_name != "":
		return debug_name

	return prop_name
