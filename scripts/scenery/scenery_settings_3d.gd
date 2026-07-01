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

# Surface hints are placeholders for later per-scenery movement tuning.
@export var surface_name: String = "sand"
@export var surface_friction_hint: float = 0.55


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
