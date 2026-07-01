extends CanvasLayer

# Lightweight "existence simulator" flavor.
# This tracks session time, shows rare optional status messages, and provides a
# simple photo mode. It intentionally does not add score, rewards, or goals.

@export var flavor_messages_enabled: bool = true
@export var flavor_message_visible_time: float = 5.0
@export var flavor_message_min_interval: float = 22.0
@export var flavor_message_max_interval: float = 42.0
@export var show_messages_in_photo_mode: bool = false

var existence_time: float = 0.0
var photo_mode_enabled: bool = false

var _message_label: Label
var _message_timer: float = 0.0
var _next_message_timer: float = 0.0
var _debug_visibility_before_photo: Dictionary = {}

const FLAVOR_MESSAGES := [
	"You are still a flipflop.",
	"The ocean does not apologize.",
	"A crab judges you silently.",
	"Nothing has been achieved.",
	"The left flipflop is still missing.",
	"You feel slightly sandy.",
]


func _ready() -> void:
	add_to_group("existence_debug")
	add_to_group("photo_mode_controller")
	_build_message_label()
	_schedule_next_message()


func _unhandled_input(event: InputEvent) -> void:
	var key_event := event as InputEventKey

	if key_event == null or not key_event.pressed or key_event.echo:
		return

	if key_event.keycode == KEY_P:
		toggle_photo_mode()
	elif key_event.keycode == KEY_F3:
		flavor_messages_enabled = not flavor_messages_enabled
		if not flavor_messages_enabled:
			_message_label.visible = false


func _process(delta: float) -> void:
	existence_time += delta
	_update_flavor_messages(delta)


func _build_message_label() -> void:
	_message_label = Label.new()
	_message_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_message_label.anchor_left = 0.5
	_message_label.anchor_right = 0.5
	_message_label.anchor_top = 1.0
	_message_label.anchor_bottom = 1.0
	_message_label.position = Vector2(-220, -88)
	_message_label.size = Vector2(440, 48)
	_message_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_message_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_message_label.add_theme_color_override("font_color", Color(0.9, 1.0, 0.92))
	_message_label.add_theme_color_override("font_shadow_color", Color(0.0, 0.0, 0.0))
	_message_label.add_theme_constant_override("shadow_offset_x", 2)
	_message_label.add_theme_constant_override("shadow_offset_y", 2)
	_message_label.visible = false
	add_child(_message_label)


func _update_flavor_messages(delta: float) -> void:
	if not flavor_messages_enabled:
		_message_label.visible = false
		return

	if photo_mode_enabled and not show_messages_in_photo_mode:
		_message_label.visible = false
		return

	if _message_timer > 0.0:
		_message_timer -= delta
		if _message_timer <= 0.0:
			_message_label.visible = false
			_schedule_next_message()
		return

	_next_message_timer -= delta
	if _next_message_timer <= 0.0:
		_show_random_message()


func _show_random_message() -> void:
	_message_label.text = FLAVOR_MESSAGES.pick_random()
	_message_label.visible = true
	_message_timer = flavor_message_visible_time


func _schedule_next_message() -> void:
	_next_message_timer = randf_range(flavor_message_min_interval, flavor_message_max_interval)


func toggle_photo_mode() -> void:
	set_photo_mode_enabled(not photo_mode_enabled)


func set_photo_mode_enabled(enabled: bool) -> void:
	if photo_mode_enabled == enabled:
		return

	photo_mode_enabled = enabled

	if photo_mode_enabled:
		_debug_visibility_before_photo.clear()
		for node in get_tree().get_nodes_in_group("debug_ui"):
			if node is CanvasItem:
				_debug_visibility_before_photo[node.get_path()] = (node as CanvasItem).visible
				(node as CanvasItem).visible = false

		if not show_messages_in_photo_mode:
			_message_label.visible = false
	else:
		for node in get_tree().get_nodes_in_group("debug_ui"):
			if node is CanvasItem:
				var previous_visible: bool = bool(_debug_visibility_before_photo.get(node.get_path(), false))
				(node as CanvasItem).visible = previous_visible

		_debug_visibility_before_photo.clear()


func get_existence_debug_state() -> Dictionary:
	return {
		"existence_time": existence_time,
		"photo_mode_enabled": photo_mode_enabled,
		"flavor_messages_enabled": flavor_messages_enabled,
		"next_message_in": _next_message_timer,
	}


func is_photo_mode_enabled() -> bool:
	return photo_mode_enabled
