class_name SceneryManager3D
extends Node

# Prototype scenery loader for Flipflop Island.
# It keeps the player/camera/debug UI persistent and swaps only the current
# playable scenery under SceneryRoot.

signal scenery_changed(scenery_id: String, display_name: String)

const DESERTED_ISLAND_ID := "deserted_island"
const RESORT_POOL_ID := "resort_pool"
const BOARDWALK_ID := "boardwalk"
const CRUISE_SHIP_DECK_ID := "cruise_ship_deck"
const LOCKER_ROOM_ID := "locker_room"

const SCENERY_SCENE_PATHS := {
	"deserted_island": "res://scenes/scenery/IslandScenery3D.tscn",
	"resort_pool": "res://scenes/scenery/ResortPoolScenery3D.tscn",
	"boardwalk": "res://scenes/scenery/BoardwalkScenery3D.tscn",
	"cruise_ship_deck": "res://scenes/scenery/CruiseShipDeckScenery3D.tscn",
	"locker_room": "res://scenes/scenery/LockerRoomScenery3D.tscn",
}

@export var scenery_root_path: NodePath
@export var player_path: NodePath
@export var ambience_path: NodePath
@export var default_scenery_id: String = DESERTED_ISLAND_ID
@export var test_selector_enabled: bool = true
@export var reset_player_on_scenery_load: bool = true

var _scenery_root: Node
var _player: Node
var _ambience: Node
var _current_scenery: Node3D
var _current_settings: ScenerySettings3D
var _current_scenery_id: String = ""


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	add_to_group("scenery_manager")
	_scenery_root = get_node_or_null(scenery_root_path)
	_player = get_node_or_null(player_path)
	_ambience = get_node_or_null(ambience_path)

	if _scenery_root == null:
		_scenery_root = self

	var fallback_scenery_id: String = SettingsManager.last_scenery_id
	if fallback_scenery_id.is_empty() or not SCENERY_SCENE_PATHS.has(fallback_scenery_id):
		fallback_scenery_id = default_scenery_id

	var starting_scenery_id: String = FlipflopUIManager.get_requested_scenery_id(
		get_tree(),
		fallback_scenery_id
	)
	if not SCENERY_SCENE_PATHS.has(starting_scenery_id):
		starting_scenery_id = default_scenery_id

	call_deferred("load_scenery", starting_scenery_id)


func _unhandled_input(event: InputEvent) -> void:
	if not test_selector_enabled or get_tree().paused:
		return

	var key_event: InputEventKey = event as InputEventKey
	if key_event == null or not key_event.pressed or key_event.echo:
		return

	if key_event.keycode == KEY_1:
		load_scenery(DESERTED_ISLAND_ID)
		get_viewport().set_input_as_handled()
	elif key_event.keycode == KEY_2:
		load_scenery(RESORT_POOL_ID)
		get_viewport().set_input_as_handled()
	elif key_event.keycode == KEY_3:
		load_scenery(BOARDWALK_ID)
		get_viewport().set_input_as_handled()
	elif key_event.keycode == KEY_4:
		load_scenery(CRUISE_SHIP_DECK_ID)
		get_viewport().set_input_as_handled()
	elif key_event.keycode == KEY_5:
		load_scenery(LOCKER_ROOM_ID)
		get_viewport().set_input_as_handled()


func load_scenery(scenery_id: String) -> void:
	if not SCENERY_SCENE_PATHS.has(scenery_id):
		push_warning("No scenery scene registered for '%s'." % scenery_id)
		return

	var scene_path: String = String(SCENERY_SCENE_PATHS[scenery_id])
	var packed_scene: PackedScene = load(scene_path) as PackedScene

	if packed_scene == null:
		push_warning("Could not load scenery scene at %s." % scene_path)
		return

	if _current_scenery != null:
		_unload_current_scenery()

	var instance: Node3D = packed_scene.instantiate() as Node3D
	if instance == null:
		push_warning("Scenery scene at %s does not have a Node3D root." % scene_path)
		return

	_scenery_root.add_child(instance)
	_current_scenery = instance
	_current_scenery_id = scenery_id
	_current_settings = _find_scenery_settings(instance)
	_apply_current_scenery_settings()
	SettingsManager.set_last_scenery_id(_current_scenery_id)

	var display_name: String = get_current_scenery_name()
	scenery_changed.emit(_current_scenery_id, display_name)


func reset_player_to_current_spawn() -> void:
	if _player == null:
		return

	var spawn: Marker3D = _get_current_spawn()
	if spawn != null and _player.has_method("set_scenery_spawn"):
		_player.call(
			"set_scenery_spawn",
			spawn.global_transform,
			_get_safe_ground_y(),
			_get_safe_ground_clearance(),
			_get_fall_reset_height()
		)

	if _player.has_method("reset_flipflop"):
		_player.call("reset_flipflop")


func reset_current_scenery_props() -> void:
	if _current_scenery == null:
		return

	for prop in get_tree().get_nodes_in_group("resettable_prop"):
		var prop_node: Node = prop as Node
		if prop_node == null or not _current_scenery.is_ancestor_of(prop_node):
			continue

		if prop_node.has_method("reset_prop"):
			prop_node.call("reset_prop")


func get_current_scenery_name() -> String:
	if _current_settings != null:
		return _current_settings.display_name

	return _current_scenery_id


func get_current_scenery_id() -> String:
	return _current_scenery_id


func _find_scenery_settings(scenery: Node) -> ScenerySettings3D:
	return scenery.find_child("ScenerySettings", true, false) as ScenerySettings3D


func _unload_current_scenery() -> void:
	var old_scenery: Node3D = _current_scenery
	_current_scenery = null
	_current_settings = null
	_current_scenery_id = ""

	if old_scenery.get_parent() != null:
		old_scenery.get_parent().remove_child(old_scenery)

	old_scenery.queue_free()


func _apply_current_scenery_settings() -> void:
	if _current_settings != null:
		_current_settings.apply_to_ambience(_ambience)
		_current_settings.apply_to_player_surface(_player)

	var spawn: Marker3D = _get_current_spawn()
	if spawn == null:
		push_warning("Scenery '%s' has no PlayerStart marker." % _current_scenery_id)
		return

	if _player != null and _player.has_method("set_scenery_spawn"):
		_player.call(
			"set_scenery_spawn",
			spawn.global_transform,
			_get_safe_ground_y(),
			_get_safe_ground_clearance(),
			_get_fall_reset_height()
		)

	if reset_player_on_scenery_load:
		reset_player_to_current_spawn()


func _get_current_spawn() -> Marker3D:
	if _current_settings != null:
		var configured_spawn: Marker3D = _current_settings.get_player_spawn()
		if configured_spawn != null:
			return configured_spawn

	if _current_scenery == null:
		return null

	return _current_scenery.find_child("PlayerStart", true, false) as Marker3D


func _get_safe_ground_y() -> float:
	if _current_settings == null:
		return 0.0

	return _current_settings.safe_ground_y


func _get_safe_ground_clearance() -> float:
	if _current_settings == null:
		return 0.18

	return _current_settings.safe_ground_clearance


func _get_fall_reset_height() -> float:
	if _current_settings == null:
		return -8.0

	return _current_settings.fall_reset_height
