extends Area3D

# Gentle wave/current zone for 3D physics bodies.
# Keep this simple for now: anything RigidBody3D inside receives a soft drift.

@export var push_strength: float = 2.2
@export var drift_direction: Vector3 = Vector3(0.7, 0.0, 0.35)
@export var wobble_amount: float = 0.25
@export var wobble_speed: float = 1.2

var _time: float = 0.0


func _physics_process(delta: float) -> void:
	_time += delta

	var wobble := Vector3(
		cos(_time * wobble_speed),
		0.0,
		sin(_time * wobble_speed)
	) * wobble_amount
	var direction := (drift_direction.normalized() + wobble).normalized()

	for body in get_overlapping_bodies():
		if body is RigidBody3D:
			body.apply_central_force(direction * push_strength)

			# TODO: Add water splash particles and bobbing feedback near shore.
