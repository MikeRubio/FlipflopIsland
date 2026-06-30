extends RigidBody2D

# Controls the lost flipflop.
# The flipflop is a RigidBody2D, so movement is handled with forces instead of
# directly changing position. This keeps the game loose and physics-driven.

@export var push_force: float = 620.0
@export var spin_force: float = 950.0
@export var max_speed: float = 520.0


func _physics_process(_delta: float) -> void:
	var move_direction := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")

	if move_direction != Vector2.ZERO:
		apply_central_force(move_direction * push_force)

		# A little torque makes the flipflop tumble as it moves.
		apply_torque(move_direction.x * spin_force)

	if linear_velocity.length() > max_speed:
		linear_velocity = linear_velocity.normalized() * max_speed
