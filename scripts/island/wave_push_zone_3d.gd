extends Area3D

# Gentle ocean/current zone for 3D physics bodies.
# The player is handled as soft water state through enter_water_zone(); loose
# props get mild drift/drag so the ocean does not behave like a solid wall.

@export var water_surface_y: float = -0.08
@export var water_safe_exit_position: Vector3 = Vector3(0.0, 0.35, 0.0)
@export var water_drag_multiplier: float = 2.5
@export var water_angular_drag_multiplier: float = 2.2
@export var water_buoyancy_force: float = 0.5
@export var water_push_to_shore_force: float = 0.24
@export var water_max_time_before_soft_reset: float = 3.5
@export_range(0.0, 1.0, 0.01) var water_spin_damping: float = 0.84
@export var splash_enabled: bool = true
@export var prop_push_strength: float = 0.25
@export var drift_direction: Vector3 = Vector3(0.7, 0.0, 0.35)
@export var wobble_amount: float = 0.08
@export var wobble_speed: float = 1.2
@export var prop_drag_multiplier: float = 0.45
@export var prop_reset_below_y: float = -2.0

@export_group("Surface Feel")
@export_enum("water", "shallow_water") var surface_type: String = "water"
@export var surface_name: String = "Ocean Water"
@export var move_force_multiplier: float = 0.5
@export var linear_damping_multiplier: float = 1.55
@export var angular_damping_multiplier: float = 1.3
@export var jump_multiplier: float = 0.72
@export var landing_impact_multiplier: float = 0.55
@export var landing_sound_type: String = "water"
@export var particle_type: String = "splash"
@export_group("")

var _time: float = 0.0
var _splash_played: bool = false


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)


func _physics_process(delta: float) -> void:
	_time += delta

	var wobble := Vector3(
		cos(_time * wobble_speed),
		0.0,
		sin(_time * wobble_speed)
	) * wobble_amount
	var direction := (drift_direction.normalized() + wobble).normalized()

	for body in get_overlapping_bodies():
		if body.has_method("enter_water_zone"):
			continue

		var rigid_body: RigidBody3D = body as RigidBody3D
		if rigid_body == null:
			continue

		rigid_body.sleeping = false
		rigid_body.apply_central_force(direction * prop_push_strength * rigid_body.mass)

		var horizontal_velocity := Vector3(
			rigid_body.linear_velocity.x,
			0.0,
			rigid_body.linear_velocity.z
		)
		rigid_body.apply_central_force(
			-horizontal_velocity
			* prop_drag_multiplier
			* rigid_body.mass
		)

		if rigid_body.global_position.y < prop_reset_below_y and rigid_body.has_method("reset_prop"):
			rigid_body.call("reset_prop")


func _on_body_entered(body: Node3D) -> void:
	if body.has_method("enter_water_zone"):
		body.call(
			"enter_water_zone",
			water_surface_y,
			water_safe_exit_position,
			water_drag_multiplier,
			water_angular_drag_multiplier,
			water_buoyancy_force,
			water_push_to_shore_force,
			water_max_time_before_soft_reset,
			water_spin_damping,
			splash_enabled,
			get_instance_id()
		)

	if body.has_method("enter_surface_zone"):
		body.call(
			"enter_surface_zone",
			surface_type,
			surface_name,
			move_force_multiplier,
			linear_damping_multiplier,
			angular_damping_multiplier,
			jump_multiplier,
			landing_impact_multiplier,
			landing_sound_type,
			particle_type,
			get_instance_id()
		)

	if not splash_enabled or _splash_played:
		return

	var audio := get_tree().get_first_node_in_group("ambience_audio")
	if audio != null and audio.has_method("play_pool_splash"):
		audio.call("play_pool_splash")

	_splash_played = true


func _on_body_exited(body: Node3D) -> void:
	if body.has_method("exit_water_zone"):
		body.call("exit_water_zone", get_instance_id())

	if body.has_method("exit_surface_zone"):
		body.call("exit_surface_zone", surface_name, get_instance_id())

	if get_overlapping_bodies().is_empty():
		_splash_played = false
