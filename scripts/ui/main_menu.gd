extends Node3D

# Visual-only main menu for Flipflop Island.
# It uses a decorative beach diorama and simple UI buttons. No player physics,
# scenery switching, debug systems, or gameplay controls run in this scene.

@export var camera_drift_speed: float = 0.22
@export var camera_drift_amount: float = 0.22
@export var ocean_motion_speed: float = 0.35
@export var ocean_motion_amount: float = 0.035
@export_file("*.tscn") var scenery_select_scene_path: String = "res://scenes/ui/ScenerySelectMenu.tscn"
@export_file("*.tscn") var options_scene_path: String = "res://scenes/ui/OptionsMenu.tscn"
@export_file("*.tscn") var controls_scene_path: String = "res://scenes/ui/ControlsMenu.tscn"

@onready var camera: Camera3D = $CameraPivot/Camera3D
@onready var camera_pivot: Node3D = $CameraPivot
@onready var water: MeshInstance3D = $MenuBeach/Water/OceanPlane
@onready var menu_panel: PanelContainer = $MenuUI/MenuRoot/MenuPanel
@onready var title_label: Label = $MenuUI/MenuRoot/MenuPanel/MarginContainer/VBoxContainer/TitleLabel
@onready var mood_label: Label = $MenuUI/MenuRoot/MoodLabel
@onready var play_button: Button = $MenuUI/MenuRoot/MenuPanel/MarginContainer/VBoxContainer/PlayButton
@onready var sceneries_button: Button = $MenuUI/MenuRoot/MenuPanel/MarginContainer/VBoxContainer/SceneriesButton
@onready var options_button: Button = $MenuUI/MenuRoot/MenuPanel/MarginContainer/VBoxContainer/OptionsButton
@onready var controls_button: Button = $MenuUI/MenuRoot/MenuPanel/MarginContainer/VBoxContainer/ControlsButton
@onready var quit_button: Button = $MenuUI/MenuRoot/MenuPanel/MarginContainer/VBoxContainer/QuitButton

var _time: float = 0.0
var _camera_base_position: Vector3
var _water_base_position: Vector3


func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	_camera_base_position = camera_pivot.position
	_water_base_position = water.position

	_apply_menu_style()
	play_button.pressed.connect(_on_play_pressed)
	sceneries_button.pressed.connect(_on_sceneries_pressed)
	options_button.pressed.connect(_on_options_pressed)
	controls_button.pressed.connect(_on_controls_pressed)
	quit_button.pressed.connect(_on_quit_pressed)
	play_button.grab_focus.call_deferred()


func _process(delta: float) -> void:
	_time += delta
	_update_camera_drift()
	_update_ocean_motion()


func _update_camera_drift() -> void:
	var side_offset: float = sin(_time * camera_drift_speed) * camera_drift_amount
	var height_offset: float = sin(_time * camera_drift_speed * 0.73) * camera_drift_amount * 0.18
	camera_pivot.position = _camera_base_position + Vector3(side_offset, height_offset, 0.0)
	camera.look_at(Vector3(0.0, 0.32, -0.25), Vector3.UP)


func _update_ocean_motion() -> void:
	var wave_offset: float = sin(_time * ocean_motion_speed) * ocean_motion_amount
	water.position = _water_base_position + Vector3(0.0, wave_offset, 0.0)


func _apply_menu_style() -> void:
	FlipflopUIStyle.apply_panel(menu_panel, 0.62)
	FlipflopUIStyle.style_title(title_label, 38)
	FlipflopUIStyle.style_body(mood_label, 16)
	for button: Button in [
		play_button,
		sceneries_button,
		options_button,
		controls_button,
		quit_button,
	]:
		FlipflopUIStyle.apply_button(button, 44.0)


func _on_play_pressed() -> void:
	FlipflopUIManager.load_game(get_tree(), FlipflopUIManager.DESERTED_ISLAND_ID)


func _on_sceneries_pressed() -> void:
	get_tree().change_scene_to_file(scenery_select_scene_path)


func _on_options_pressed() -> void:
	get_tree().change_scene_to_file(options_scene_path)


func _on_controls_pressed() -> void:
	get_tree().change_scene_to_file(controls_scene_path)


func _on_quit_pressed() -> void:
	get_tree().quit()
