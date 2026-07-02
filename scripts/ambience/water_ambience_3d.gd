extends MeshInstance3D

# Tiny water visual animator.
# This moves the placeholder water plane gently and scrolls its material color
# a little so the ocean feels alive without requiring a shader.

@export var wave_enabled: bool = true
@export var wave_speed: float = 0.55
@export var bob_amplitude: float = 0.035
@export var color_pulse_amount: float = 0.08
@export var base_color: Color = Color(0.02, 0.3, 0.42, 0.72)
@export var highlight_color: Color = Color(0.08, 0.48, 0.62, 0.72)
@export var material_roughness: float = 0.16

var _start_position: Vector3
var _time: float = 0.0
var _material: StandardMaterial3D


func _ready() -> void:
	_start_position = position

	var original_material := get_active_material(0) as StandardMaterial3D
	if original_material != null:
		_material = original_material.duplicate() as StandardMaterial3D
		_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		_material.roughness = material_roughness
		_material.albedo_color = base_color
		set_surface_override_material(0, _material)


func _process(delta: float) -> void:
	if not wave_enabled:
		return

	_time += delta * wave_speed
	position.y = _start_position.y + sin(_time) * bob_amplitude

	if _material != null:
		var pulse_amount: float = (sin(_time * 0.7) * 0.5 + 0.5) * color_pulse_amount
		_material.albedo_color = base_color.lerp(highlight_color, pulse_amount)
