class_name CruiseShipMotion3D
extends Area3D

# Subtle prototype motion for the Cruise Ship Deck scenery.
# This does not move the floor collision. Instead it applies tiny horizontal
# forces to the flipflop and loose props inside the deck area, which feels like
# sway/wind without making the physics unstable.

@export var ship_sway_enabled: bool = true
@export var ship_sway_strength: float = 0.055
@export var ship_sway_speed: float = 0.45
@export var wind_push_enabled: bool = true
@export var wind_push_strength: float = 0.028
@export var wind_direction: Vector3 = Vector3(1.0, 0.0, 0.18)

var _time: float = 0.0
var _last_sway_force: Vector3 = Vector3.ZERO
var _last_wind_force: Vector3 = Vector3.ZERO
var _affected_body_count: int = 0


func _ready() -> void:
	add_to_group("ship_motion_debug")


func _physics_process(delta: float) -> void:
	_time += delta
	_last_sway_force = _calculate_sway_force()
	_last_wind_force = _calculate_wind_force()
	_affected_body_count = 0

	var combined_force: Vector3 = _last_sway_force + _last_wind_force
	if combined_force.length_squared() <= 0.000001:
		return

	var bodies: Array[Node3D] = get_overlapping_bodies()
	for body in bodies:
		var rigid_body: RigidBody3D = body as RigidBody3D
		if rigid_body == null:
			continue

		rigid_body.sleeping = false
		rigid_body.apply_central_force(combined_force * rigid_body.mass)
		_affected_body_count += 1


func _calculate_sway_force() -> Vector3:
	if not ship_sway_enabled:
		return Vector3.ZERO

	var sway_x: float = sin(_time * ship_sway_speed)
	var sway_z: float = cos(_time * ship_sway_speed * 0.63) * 0.35
	return Vector3(sway_x, 0.0, sway_z) * ship_sway_strength


func _calculate_wind_force() -> Vector3:
	if not wind_push_enabled:
		return Vector3.ZERO

	var direction: Vector3 = wind_direction
	direction.y = 0.0

	if direction.length() < 0.001:
		return Vector3.ZERO

	return direction.normalized() * wind_push_strength


func get_ship_motion_debug_state() -> Dictionary:
	return {
		"ship_sway_enabled": ship_sway_enabled,
		"ship_sway_strength": ship_sway_strength,
		"ship_sway_speed": ship_sway_speed,
		"wind_push_enabled": wind_push_enabled,
		"wind_push_strength": wind_push_strength,
		"wind_direction": wind_direction,
		"sway_force": _last_sway_force,
		"wind_force": _last_wind_force,
		"affected_body_count": _affected_body_count,
	}
