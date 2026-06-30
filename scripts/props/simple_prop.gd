extends RigidBody2D

# Shared behavior for small island props like coconuts, driftwood, and the crab.
# Props can be bumped by physics, pushed by waves, or clicked/tapped for a small nudge.

@export var prop_name: String = "Island Prop"
@export var wake_up_impulse: float = 70.0


func _ready() -> void:
	input_pickable = true


func nudge(direction: Vector2) -> void:
	if direction == Vector2.ZERO:
		direction = Vector2.RIGHT

	apply_central_impulse(direction.normalized() * wake_up_impulse)
	apply_torque_impulse(randf_range(-wake_up_impulse, wake_up_impulse))


func _input_event(_viewport: Viewport, event: InputEvent, _shape_idx: int) -> void:
	var mouse_event := event as InputEventMouseButton

	if mouse_event != null and mouse_event.pressed:
		var push_direction := global_position - get_global_mouse_position()
		nudge(push_direction)
