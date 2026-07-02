class_name FlipflopUIManager
extends RefCounted

# Shared UI helpers for Flipflop Island menus.
# These helpers keep menu navigation simple and avoid duplicating scene paths,
# scenery IDs, and runtime option application across several menu screens.

const MAIN_MENU_SCENE_PATH := "res://scenes/ui/MainMenu.tscn"
const GAME_SCENE_PATH := "res://scenes/main/Main3D.tscn"
const REQUESTED_SCENERY_META := "flipflop_requested_scenery_id"

const DESERTED_ISLAND_ID := "deserted_island"
const RESORT_POOL_ID := "resort_pool"
const BOARDWALK_ID := "boardwalk"
const CRUISE_SHIP_DECK_ID := "cruise_ship_deck"
const LOCKER_ROOM_ID := "locker_room"

const SCENERY_DISPLAY_NAMES := {
	"deserted_island": "Deserted Island",
	"resort_pool": "Resort Pool",
	"boardwalk": "Boardwalk",
	"cruise_ship_deck": "Cruise Ship Deck",
	"locker_room": "Locker Room / Public Shower",
}

static func load_game(tree: SceneTree, scenery_id: String = DESERTED_ISLAND_ID) -> void:
	tree.paused = false
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	SettingsManager.set_last_scenery_id(scenery_id)
	tree.set_meta(REQUESTED_SCENERY_META, scenery_id)
	tree.change_scene_to_file(GAME_SCENE_PATH)


static func load_main_menu(tree: SceneTree) -> void:
	tree.paused = false
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	tree.change_scene_to_file(MAIN_MENU_SCENE_PATH)


static func get_requested_scenery_id(tree: SceneTree, fallback_id: String) -> String:
	if not tree.has_meta(REQUESTED_SCENERY_META):
		return fallback_id

	var requested_id: String = String(tree.get_meta(REQUESTED_SCENERY_META))
	tree.remove_meta(REQUESTED_SCENERY_META)

	if requested_id.is_empty():
		return fallback_id

	return requested_id


static func get_scenery_display_name(scenery_id: String) -> String:
	if SCENERY_DISPLAY_NAMES.has(scenery_id):
		return String(SCENERY_DISPLAY_NAMES[scenery_id])

	return scenery_id
