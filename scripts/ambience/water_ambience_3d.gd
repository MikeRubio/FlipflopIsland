extends MeshInstance3D

# Tiny water visual animator.
# This moves the placeholder water plane gently and scrolls its material color
# a little so the ocean feels alive without requiring a shader.

@export var wave_enabled: bool = true
@export var wave_speed: float = 0.55
@export var bob_amplitude: float = 0.035
@export var color_pulse_amount: float = 0.08

var _start_position: Vector3
var _time: float = 0.0
var _material: StandardMaterial3D


func _ready() -> void:
	_start_position = position

	var original_material := get_active_material(0) as StandardMaterial3D
	if original_material != null:
		_material = original_material.duplicate() as StandardMaterial3D
		set_surface_override_material(0, _material)


func _process(delta: float) -> void:
	if not wave_enabled:
		return

	_time += delta * wave_speed
	position.y = _start_position.y + sin(_time) * bob_amplitude

	if _material != null:
		var pulse := sin(_time * 0.7) * color_pulse_amount
		_material.albedo_color = Color(0.02 + pulse * 0.2, 0.3 + pulse, 0.42 + pulse, 0.72)
