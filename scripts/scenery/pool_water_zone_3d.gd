class_name PoolWaterZone3D
extends Area3D

# Simple water volume for the resort pool.
# Bodies inside get gentle buoyancy, drag, and drift. If the flipflop sinks too
# low, it is reset to the current scenery spawn instead of taking damage.

@export var water_surface_y: float = 0.02
@export var buoyancy_force: float = 1.25
@export var horizontal_drag: float = 0.65
@export var water_drift_force: float = 0.08
@export var drift_direction: Vector3 = Vector3(0.4, 0.0, 0.2)
@export var reset_below_y: float = -1.2
@export var splash_cooldown: float = 0.45

@export_group("Surface Feel")
@export_enum("water", "shallow_water") var surface_type: String = "water"
@export var surface_name: String = "Pool Water"
@export var move_force_multiplier: float = 0.55
@export var linear_damping_multiplier: float = 1.45
@export var angular_damping_multiplier: float = 1.25
@export var jump_multiplier: float = 0.75
@export var landing_impact_multiplier: float = 0.55
@export var landing_sound_type: String = "water"
@export var particle_type: String = "splash"

var _splash_timer: float = 0.0


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)


func _physics_process(delta: float) -> void:
	_splash_timer = maxf(_splash_timer - delta, 0.0)

	var bodies: Array[Node3D] = get_overlapping_bodies()
	for body in bodies:
		var rigid_body: RigidBody3D = body as RigidBody3D
		if rigid_body == null:
			continue

		_apply_water_motion(rigid_body)
		_recover_if_too_deep(rigid_body)


func _apply_water_motion(body: RigidBody3D) -> void:
	body.sleeping = false

	var depth := maxf(0.0, water_surface_y - body.global_position.y)
	var buoyancy := Vector3.UP * buoyancy_force * body.mass * (1.0 + depth)
	body.apply_central_force(buoyancy)

	var horizontal_velocity := Vector3(body.linear_velocity.x, 0.0, body.linear_velocity.z)
	body.apply_central_force(-horizontal_velocity * horizontal_drag * body.mass)

	var drift := drift_direction
	drift.y = 0.0
	if drift.length() > 0.001:
		body.apply_central_force(drift.normalized() * water_drift_force * body.mass)


func _recover_if_too_deep(body: RigidBody3D) -> void:
	if body.global_position.y >= reset_below_y:
		return

	if body.has_method("reset_flipflop"):
		body.call("reset_flipflop")
	elif body.has_method("reset_prop"):
		body.call("reset_prop")


func _on_body_entered(body: Node3D) -> void:
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

	if _splash_timer > 0.0:
		return

	var audio := get_tree().get_first_node_in_group("ambience_audio")
	if audio != null and audio.has_method("play_pool_splash"):
		audio.call("play_pool_splash")

	_splash_timer = splash_cooldown


func _on_body_exited(body: Node3D) -> void:
	if body.has_method("exit_surface_zone"):
		body.call("exit_surface_zone", surface_name, get_instance_id())
