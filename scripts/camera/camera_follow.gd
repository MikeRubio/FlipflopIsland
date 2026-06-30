extends Camera2D

# Smoothly follows a target Node2D.
# In Main.tscn, target_path points at the FlipflopPlayer.

@export var target_path: NodePath
@export var follow_speed: float = 6.0

var _target: Node2D


func _ready() -> void:
	if target_path != NodePath(""):
		_target = get_node_or_null(target_path) as Node2D


func _process(delta: float) -> void:
	if _target == null:
		return

	var follow_amount := clampf(delta * follow_speed, 0.0, 1.0)
	global_position = global_position.lerp(_target.global_position, follow_amount)
