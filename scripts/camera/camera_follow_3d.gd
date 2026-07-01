extends Camera3D

# Simple third-person orbit camera.
# Godot 3D uses Y as up, so mouse X changes yaw around the Y axis and mouse Y
# changes pitch around the X axis. The camera never rolls around Z.

@export var target_path: NodePath

# Mouse look tuning. Set invert_y to true if you prefer flight-sim style pitch.
@export var mouse_sensitivity: float = 0.003
@export var invert_y: bool = false

# Pitch is stored in degrees for easy tuning in the Inspector.
@export var min_pitch: float = -10.0
@export var max_pitch: float = 32.0

# Scroll wheel zoom tuning.
@export var min_zoom_distance: float = 1.2
@export var max_zoom_distance: float = 8.0
@export var default_zoom_distance: float = 3.4
@export var zoom_speed: float = 0.45

# Follow/rotation smoothing. Higher values catch up faster.
@export var follow_smoothing: float = 10.0
@export var rotation_smoothing: float = 18.0

# The camera orbits around target + camera_height and looks at target +
# look_at_height. Keep both low so the flipflop feels close to the sand.
@export var camera_height: float = 0.55
@export var look_at_height: float = 0.22

# Minimum world Y for the camera body. This prevents the camera from dipping
# into the water/sand when pitched low.
@export var ground_clearance: float = 0.22

# Optional simple obstruction check from target to camera.
@export var collision_mask: int = 1
@export var collision_margin: float = 0.18
@export var camera_shake_enabled: bool = true

# Calm idle camera. If the player does nothing for a while, the camera slowly
# orbits the flipflop like a tiny existence simulator screen saver.
@export var idle_orbit_enabled: bool = true
@export var idle_orbit_delay: float = 12.0
@export var idle_orbit_speed: float = 0.08

var _target: Node3D
var _focus_position: Vector3 = Vector3.ZERO
var _yaw: float = 0.0
var _pitch: float = deg_to_rad(12.0)
var _target_yaw: float = 0.0
var _target_pitch: float = deg_to_rad(12.0)
var _zoom_distance: float = 3.4
var _target_zoom_distance: float = 3.4
var _bump_offset: float = 0.0
var _idle_timer: float = 0.0


func _ready() -> void:
	if target_path != NodePath(""):
		_target = get_node_or_null(target_path) as Node3D

	_zoom_distance = clampf(default_zoom_distance, min_zoom_distance, max_zoom_distance)
	_target_zoom_distance = _zoom_distance
	_focus_position = _target.global_position if _target != null else global_position
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _input(event: InputEvent) -> void:
	if get_tree().paused:
		return

	var mouse_motion := event as InputEventMouseMotion

	if mouse_motion != null:
		if Input.mouse_mode != Input.MOUSE_MODE_CAPTURED:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

		_mark_player_input()
		_target_yaw -= mouse_motion.relative.x * mouse_sensitivity

		var y_sign := 1.0 if invert_y else -1.0
		_target_pitch += mouse_motion.relative.y * mouse_sensitivity * y_sign
		_target_pitch = clampf(
			_target_pitch,
			deg_to_rad(min_pitch),
			deg_to_rad(max_pitch)
		)
		return

	var mouse_button := event as InputEventMouseButton

	if mouse_button != null and mouse_button.pressed:
		_mark_player_input()

		if mouse_button.button_index == MOUSE_BUTTON_WHEEL_UP:
			_target_zoom_distance = maxf(
				_target_zoom_distance - zoom_speed,
				min_zoom_distance
			)
		elif mouse_button.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			_target_zoom_distance = minf(
				_target_zoom_distance + zoom_speed,
				max_zoom_distance
			)
		elif Input.mouse_mode != Input.MOUSE_MODE_CAPTURED:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

		return

	var key_event := event as InputEventKey

	if key_event != null and key_event.pressed and not key_event.echo:
		_mark_player_input()


func _process(delta: float) -> void:
	if _target == null:
		return

	var follow_amount := clampf(delta * follow_smoothing, 0.0, 1.0)
	var rotation_amount := clampf(delta * rotation_smoothing, 0.0, 1.0)

	_update_idle_orbit(delta)

	_focus_position = _focus_position.lerp(_target.global_position, follow_amount)
	_yaw = lerp_angle(_yaw, _target_yaw, rotation_amount)
	_pitch = lerpf(_pitch, _target_pitch, rotation_amount)
	_zoom_distance = lerpf(_zoom_distance, _target_zoom_distance, rotation_amount)

	var orbit_center := _focus_position + Vector3.UP * camera_height
	var look_point := _focus_position + Vector3.UP * look_at_height
	var desired_position := orbit_center + _get_orbit_offset()
	desired_position = _apply_camera_collision(look_point, desired_position)

	_bump_offset = lerpf(_bump_offset, 0.0, clampf(delta * 10.0, 0.0, 1.0))
	desired_position.y = maxf(desired_position.y + _bump_offset, ground_clearance)

	global_position = desired_position
	look_at(look_point, Vector3.UP)


func _get_orbit_offset() -> Vector3:
	var horizontal_distance := cos(_pitch) * _zoom_distance

	return Vector3(
		sin(_yaw) * horizontal_distance,
		sin(_pitch) * _zoom_distance,
		cos(_yaw) * horizontal_distance
	)


func _apply_camera_collision(from_position: Vector3, desired_position: Vector3) -> Vector3:
	if collision_mask == 0:
		return desired_position

	var space_state := get_world_3d().direct_space_state
	var query := PhysicsRayQueryParameters3D.create(from_position, desired_position)
	query.collision_mask = collision_mask
	query.exclude = []

	if _target is CollisionObject3D:
		query.exclude.append((_target as CollisionObject3D).get_rid())

	var hit := space_state.intersect_ray(query)

	if hit.is_empty():
		return desired_position

	var hit_position: Vector3 = hit["position"]
	var safe_direction := from_position - desired_position

	if safe_direction.length() < 0.001:
		return hit_position

	safe_direction = safe_direction.normalized()
	return hit_position + safe_direction * collision_margin


func get_camera_yaw_axes() -> Dictionary:
	# Movement uses yaw only, not camera pitch or the flipflop's tumble.
	# At yaw 0, the camera sits on +Z and W moves toward -Z.
	var forward := Vector3(-sin(_yaw), 0.0, -cos(_yaw)).normalized()
	var right := Vector3(cos(_yaw), 0.0, -sin(_yaw)).normalized()

	return {
		"forward": forward,
		"right": right,
	}


func bump(amount: float = 0.08) -> void:
	# Placeholder camera feedback hook for hard flipflop landings.
	if not camera_shake_enabled:
		return

	_bump_offset = amount


func set_camera_shake_enabled(enabled: bool) -> void:
	camera_shake_enabled = enabled


func _update_idle_orbit(delta: float) -> void:
	if _has_active_gameplay_input():
		_mark_player_input()
		return

	_idle_timer += delta

	if idle_orbit_enabled and _idle_timer >= idle_orbit_delay:
		_target_yaw += idle_orbit_speed * delta


func _mark_player_input() -> void:
	_idle_timer = 0.0


func _has_active_gameplay_input() -> bool:
	return (
		Input.is_key_pressed(KEY_W)
		or Input.is_key_pressed(KEY_A)
		or Input.is_key_pressed(KEY_S)
		or Input.is_key_pressed(KEY_D)
		or Input.is_key_pressed(KEY_UP)
		or Input.is_key_pressed(KEY_DOWN)
		or Input.is_key_pressed(KEY_LEFT)
		or Input.is_key_pressed(KEY_RIGHT)
		or Input.is_key_pressed(KEY_SPACE)
		or Input.is_key_pressed(KEY_Q)
		or Input.is_key_pressed(KEY_E)
		or Input.is_key_pressed(KEY_R)
		or Input.is_key_pressed(KEY_C)
	)
