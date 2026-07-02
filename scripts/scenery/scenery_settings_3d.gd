class_name ScenerySettings3D
extends Node

# Small data node used by the SceneryManager.
# Put one ScenerySettings node inside each playable scenery so the manager knows
# where the flipflop should spawn and which broad ambience/surface values apply.

@export var scenery_id: String = "deserted_island"
@export var display_name: String = "Deserted Island"

# Usually points to ../SpawnPoints/PlayerStart from this settings node.
@export var player_spawn_path: NodePath

# Optional root that contains movable props. Props still store their own start
# transforms, but this gives future tooling one obvious place to look.
@export var prop_reset_root_path: NodePath

# Player safety values for this scenery. The player script uses these for R
# reset and under-ground recovery.
@export var safe_ground_y: float = 0.0
@export var safe_ground_clearance: float = 0.18
@export var fall_reset_height: float = -8.0

# Simple ambience hooks. The global ambience controller reads these when the
# scenery loads; they are mood settings, not gameplay rules.
@export var ambience_zone: String = "open island"
@export var day_night_cycle_enabled: bool = true
@export_range(0.0, 1.0, 0.001) var time_of_day: float = 0.42
@export var cycle_speed: float = 0.006

@export_group("Lighting Profile")
@export var directional_light_energy_multiplier: float = 1.0
@export var ambient_light_energy_multiplier: float = 1.0
@export var sky_brightness_multiplier: float = 1.0
@export var directional_light_tint: Color = Color(1.0, 1.0, 1.0)
@export var ambient_light_tint: Color = Color(1.0, 1.0, 1.0)
@export var sky_tint: Color = Color(1.0, 1.0, 1.0)

# Default surface for the scenery. Specific Area3D SurfaceZone nodes can
# override this while the flipflop is inside them.
@export_enum("sand", "wet_tile", "dry_tile", "wood", "water", "shallow_water", "custom")
var surface_type: String = "sand"
@export var surface_name: String = "Sand"
@export var surface_friction_hint: float = 0.55
@export var surface_move_multiplier: float = 0.88
@export var surface_linear_damping_multiplier: float = 1.18
@export var surface_angular_damping_multiplier: float = 1.08
@export var surface_jump_multiplier: float = 0.94
@export var surface_landing_impact_multiplier: float = 0.75
@export var surface_landing_sound_type: String = "sand"
@export var surface_particle_type: String = "sand"


func get_player_spawn() -> Marker3D:
	if player_spawn_path != NodePath(""):
		var configured_spawn: Marker3D = get_node_or_null(player_spawn_path) as Marker3D
		if configured_spawn != null:
			return configured_spawn

	var scenery_root: Node = get_parent()
	if scenery_root == null:
		return null

	return scenery_root.find_child("PlayerStart", true, false) as Marker3D


func get_prop_reset_root() -> Node:
	if prop_reset_root_path != NodePath(""):
		var configured_root: Node = get_node_or_null(prop_reset_root_path)
		if configured_root != null:
			return configured_root

	var scenery_root: Node = get_parent()
	if scenery_root == null:
		return null

	return scenery_root.find_child("PhysicsProps", true, false)


func apply_to_ambience(ambience: Node) -> void:
	if ambience == null:
		return

	ambience.set("day_night_cycle_enabled", day_night_cycle_enabled)
	ambience.set("time_of_day", time_of_day)
	ambience.set("cycle_speed", cycle_speed)
	ambience.set("ambience_zone", ambience_zone)
	ambience.set("directional_light_energy_multiplier", directional_light_energy_multiplier)
	ambience.set("ambient_light_energy_multiplier", ambient_light_energy_multiplier)
	ambience.set("sky_brightness_multiplier", sky_brightness_multiplier)
	ambience.set("directional_light_tint", directional_light_tint)
	ambience.set("ambient_light_tint", ambient_light_tint)
	ambience.set("sky_tint", sky_tint)


func apply_to_player_surface(player: Node) -> void:
	if player == null or not player.has_method("set_default_surface"):
		return

	player.call(
		"set_default_surface",
		surface_type,
		surface_name,
		surface_move_multiplier,
		surface_linear_damping_multiplier,
		surface_angular_damping_multiplier,
		surface_jump_multiplier,
		surface_landing_impact_multiplier,
		surface_landing_sound_type,
		surface_particle_type
	)
