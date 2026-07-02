class_name PoolWaterZone3D
extends Area3D

# Simple water volume for the resort pool.
# The flipflop receives water behavior through enter_water_zone(), so water is
# a soft trigger volume instead of a solid collider. Loose props still receive
# small forces here so they float, slow down, and drift without exploding.

@export var water_surface_y: float = 0.02
@export var water_safe_exit_position: Vector3 = Vector3(10.0, 0.35, 0.0)
@export var water_drag_multiplier: float = 2.2
@export var water_angular_drag_multiplier: float = 1.9
@export var water_buoyancy_force: float = 0.6
@export var water_push_to_shore_force: float = 0.28
@export var water_max_time_before_soft_reset: float = 3.0
@export_range(0.0, 1.0, 0.01) var water_spin_damping: float = 0.84
@export var prop_reset_below_y: float = -1.2
@export var splash_cooldown: float = 0.45
@export var splash_enabled: bool = true

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
		if body.has_method("enter_water_zone"):
			continue

		var rigid_body: RigidBody3D = body as RigidBody3D
		if rigid_body == null:
			continue

		_apply_water_motion(rigid_body, delta)
		_recover_if_too_deep(rigid_body)


func _apply_water_motion(body: RigidBody3D, delta: float) -> void:
	body.sleeping = false

	var depth := maxf(0.0, water_surface_y - body.global_position.y)
	var buoyancy := Vector3.UP * water_buoyancy_force * body.mass * (1.0 + minf(depth, 1.2))
	body.apply_central_force(buoyancy)

	var horizontal_velocity := Vector3(body.linear_velocity.x, 0.0, body.linear_velocity.z)
	body.apply_central_force(-horizontal_velocity * water_drag_multiplier * body.mass)
	body.angular_velocity *= pow(clampf(water_spin_damping, 0.0, 1.0), delta * 60.0)

	var shore_direction := water_safe_exit_position - body.global_position
	shore_direction.y = 0.0
	if shore_direction.length() > 0.1:
		body.apply_central_force(
			shore_direction.normalized()
			* water_push_to_shore_force
			* body.mass
		)


func _recover_if_too_deep(body: RigidBody3D) -> void:
	if body.global_position.y >= prop_reset_below_y:
		return

	if body.has_method("reset_prop"):
		body.call("reset_prop")


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

	if not splash_enabled or _splash_timer > 0.0:
		return

	var audio: Node = get_tree().get_first_node_in_group("ambience_audio")
	if audio != null and audio.has_method("play_pool_splash"):
		audio.call("play_pool_splash")

	_splash_timer = splash_cooldown


func _on_body_exited(body: Node3D) -> void:
	if body.has_method("exit_water_zone"):
		body.call("exit_water_zone", get_instance_id())

	if body.has_method("exit_surface_zone"):
		body.call("exit_surface_zone", surface_name, get_instance_id())
