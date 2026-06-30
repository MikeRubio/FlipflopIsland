extends Area2D

# Adds a gentle ocean-current force to physics bodies inside this area.
# This is intentionally simple, so the direction and strength can be tweaked
# from the Inspector without touching code.

@export var push_strength: float = 28.0
@export var drift_direction: Vector2 = Vector2(1.0, 0.25)
@export var wobble_amount: float = 0.35
@export var wobble_speed: float = 1.4

var _time: float = 0.0


func _physics_process(delta: float) -> void:
	_time += delta

	var wobble := Vector2(cos(_time * wobble_speed), sin(_time * wobble_speed)) * wobble_amount
	var direction := (drift_direction.normalized() + wobble).normalized()

	for body in get_overlapping_bodies():
		if body is RigidBody2D:
			body.apply_central_force(direction * push_strength)
