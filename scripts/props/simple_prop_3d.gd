extends RigidBody3D

# Shared behavior for simple 3D island props.
# Props are physics objects that can be bumped by the flipflop or nudged later.
# Each prop scene can tune its own mass, bounce, friction, and damping from the
# Inspector without needing a custom script per object type.

@export var prop_name: String = "Island Prop"

# Heavier props need more flipflop impact to move. Lighter props scatter easily.
@export var prop_mass: float = 1.0

# Bounce controls how lively collisions feel. A beach ball wants more bounce than
# a shell or log.
@export_range(0.0, 1.0, 0.01) var bounce: float = 0.25

# Friction controls how quickly a prop stops sliding against the sand.
@export_range(0.0, 2.0, 0.01) var friction: float = 0.7

# Damping calms props down so they settle instead of spinning forever.
@export var prop_linear_damp: float = 0.7
@export var prop_angular_damp: float = 0.9

# Props that fall below this height are reset to where they started.
@export var fall_reset_height: float = -5.0

@export var nudge_impulse: float = 2.5

var _start_transform: Transform3D


func _ready() -> void:
	input_ray_pickable = true
	_start_transform = global_transform
	mass = prop_mass
	linear_damp = prop_linear_damp
	angular_damp = prop_angular_damp

	var material: PhysicsMaterial = physics_material_override

	if material == null:
		material = PhysicsMaterial.new()
	else:
		material = material.duplicate() as PhysicsMaterial

	material.bounce = bounce
	material.friction = friction
	physics_material_override = material


func _physics_process(_delta: float) -> void:
	if global_position.y < fall_reset_height:
		reset_prop()


func nudge(direction: Vector3) -> void:
	if direction == Vector3.ZERO:
		direction = Vector3.RIGHT

	apply_central_impulse(direction.normalized() * nudge_impulse)
	apply_torque_impulse(Vector3(
		randf_range(-nudge_impulse, nudge_impulse),
		randf_range(-nudge_impulse, nudge_impulse),
		randf_range(-nudge_impulse, nudge_impulse)
	))


func _input_event(
	_camera: Camera3D,
	event: InputEvent,
	event_position: Vector3,
	_normal: Vector3,
	_shape_idx: int
) -> void:
	var mouse_event := event as InputEventMouseButton

	if mouse_event == null or not mouse_event.pressed:
		return

	nudge(global_position - event_position)


func reset_prop() -> void:
	global_transform = _start_transform
	linear_velocity = Vector3.ZERO
	angular_velocity = Vector3.ZERO
	sleeping = false
