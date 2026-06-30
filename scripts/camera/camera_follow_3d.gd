extends Camera3D

# Third-person orbit camera for the flipflop.
# This script lives directly on the Camera3D. It smoothly follows the player,
# rotates around them with the mouse, and looks at a low point near the ground so
# the flipflop feels small instead of like a strategy-game unit.

@export var target_path: NodePath

# Mouse look speed. Smaller values feel slower and easier to control.
@export var mouse_sensitivity: float = 0.003

# How far behind the flipflop the camera sits.
@export var camera_distance: float = 6.2

# How high above the flipflop the camera looks. Keep this low for a toy-like view.
@export var camera_height: float = 1.35

# Pitch limits in degrees. These stop the camera from flipping upside down.
@export var min_pitch: float = -14.0
@export var max_pitch: float = 34.0

# Follow smoothing controls how quickly the camera catches up to the flipflop.
@export var follow_smoothing: float = 8.0

# Rotation smoothing controls how quickly mouse rotation is applied.
@export var rotation_smoothing: float = 14.0

# Extra safety so the camera does not sink into the sand/water plane.
@export var minimum_world_height: float = 0.35

var _target: Node3D
var _yaw: float = 0.0
var _pitch: float = deg_to_rad(14.0)
var _target_yaw: float = 0.0
var _target_pitch: float = deg_to_rad(14.0)
var _bump_offset: float = 0.0


func _ready() -> void:
	if target_path != NodePath(""):
		_target = get_node_or_null(target_path) as Node3D

	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _unhandled_input(event: InputEvent) -> void:
	var mouse_motion := event as InputEventMouseMotion

	if mouse_motion != null and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		_target_yaw -= mouse_motion.relative.x * mouse_sensitivity
		_target_pitch -= mouse_motion.relative.y * mouse_sensitivity
		_target_pitch = clampf(
			_target_pitch,
			deg_to_rad(min_pitch),
			deg_to_rad(max_pitch)
		)
		return

	var key_event := event as InputEventKey

	if key_event != null and key_event.pressed and not key_event.echo:
		if key_event.keycode == KEY_ESCAPE:
			_toggle_mouse_capture()
		return

	var mouse_button := event as InputEventMouseButton

	if (
		mouse_button != null
		and mouse_button.pressed
		and Input.mouse_mode != Input.MOUSE_MODE_CAPTURED
	):
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _process(delta: float) -> void:
	if _target == null:
		return

	var rotation_amount := clampf(delta * rotation_smoothing, 0.0, 1.0)
	_yaw = lerp_angle(_yaw, _target_yaw, rotation_amount)
	_pitch = lerpf(_pitch, _target_pitch, rotation_amount)

	var follow_amount := clampf(delta * follow_smoothing, 0.0, 1.0)
	var focus_point := _target.global_position + Vector3.UP * camera_height
	var offset := _get_orbit_offset()
	var desired_position := focus_point + offset

	_bump_offset = lerpf(_bump_offset, 0.0, clampf(delta * 10.0, 0.0, 1.0))
	desired_position.y = maxf(desired_position.y + _bump_offset, minimum_world_height)

	global_position = global_position.lerp(desired_position, follow_amount)
	look_at(focus_point, Vector3.UP)


func _get_orbit_offset() -> Vector3:
	var horizontal_distance := cos(_pitch) * camera_distance

	return Vector3(
		sin(_yaw) * horizontal_distance,
		sin(_pitch) * camera_distance,
		cos(_yaw) * horizontal_distance
	)


func bump(amount: float = 0.18) -> void:
	# Placeholder camera feedback hook for hard flipflop landings.
	_bump_offset = amount


func _toggle_mouse_capture() -> void:
	if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	else:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
