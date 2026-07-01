class_name SurfaceZone3D
extends Area3D

# Prototype surface modifier for scenery-specific floor feel.
# Add this as an Area3D over a patch of ground. While the flipflop is inside,
# the player script combines these values with the active movement preset.

@export_enum("sand", "wet_tile", "dry_tile", "wood", "water", "shallow_water", "custom")
var surface_type: String = "wet_tile"
@export var surface_name: String = "Wet Tile"

# Values below are multipliers, so 1.0 means "leave the preset alone".
@export var move_force_multiplier: float = 0.8
@export var linear_damping_multiplier: float = 0.55
@export var angular_damping_multiplier: float = 0.9
@export var jump_multiplier: float = 0.95
@export var landing_impact_multiplier: float = 0.9
@export var landing_sound_type: String = "wet_tile"
@export var particle_type: String = "splash"

# A tiny drift force can sell a slick surface without turning it into ice.
@export var slide_force: float = 0.0
@export var slide_direction: Vector3 = Vector3.ZERO


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)


func _physics_process(_delta: float) -> void:
	if slide_force <= 0.0:
		return

	var direction := slide_direction
	direction.y = 0.0

	if direction.length() < 0.001:
		return

	direction = direction.normalized()

	var bodies: Array[Node3D] = get_overlapping_bodies()
	for body in bodies:
		var rigid_body: RigidBody3D = body as RigidBody3D
		if rigid_body == null:
			continue

		rigid_body.apply_central_force(direction * slide_force)


func _on_body_entered(body: Node3D) -> void:
	if body.has_method("enter_surface_zone"):
		body.call(
			"enter_surface_zone",
			surface_type,
			surface_name,
			move_force_multiplier,
			linear_damping_multiplier,
			angular_damping_multiplier,
			jump_multiplier,
			landing_impact_multiplier,
			landing_sound_type,
			particle_type,
			get_instance_id()
		)


func _on_body_exited(body: Node3D) -> void:
	if body.has_method("exit_surface_zone"):
		body.call("exit_surface_zone", surface_name, get_instance_id())
