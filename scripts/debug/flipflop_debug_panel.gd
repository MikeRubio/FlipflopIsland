extends CanvasLayer

# Temporary tuning panel for the 3D flipflop controller.
# This is intentionally plain: it is a quick in-game readout for tuning physics,
# not a final game menu.

@export var player_path: NodePath
@export var panel_visible_by_default: bool = false

var _player: Node
var _label: Label


func _ready() -> void:
	_player = get_node_or_null(player_path)
	_build_label()
	visible = panel_visible_by_default


func _unhandled_input(event: InputEvent) -> void:
	var key_event := event as InputEventKey

	if key_event == null or not key_event.pressed or key_event.echo:
		return

	if key_event.keycode == KEY_F1:
		visible = not visible
	elif key_event.keycode == KEY_F2:
		_cycle_player_preset()


func _process(_delta: float) -> void:
	if not visible:
		return

	if _player == null or not _player.has_method("get_movement_debug_state"):
		_label.text = "Flipflop Debug\nPlayer not found."
		return

	var state: Dictionary = _player.call("get_movement_debug_state")
	_label.text = _format_state(state)


func _build_label() -> void:
	_label = Label.new()
	_label.position = Vector2(16, 16)
	_label.size = Vector2(360, 320)
	_label.add_theme_color_override("font_color", Color(0.9, 1.0, 0.92))
	_label.add_theme_color_override("font_shadow_color", Color(0.0, 0.0, 0.0))
	_label.add_theme_constant_override("shadow_offset_x", 2)
	_label.add_theme_constant_override("shadow_offset_y", 2)
	add_child(_label)


func _cycle_player_preset() -> void:
	if _player == null or not _player.has_method("cycle_movement_preset"):
		return

	_player.call("cycle_movement_preset")


func _format_state(state: Dictionary) -> String:
	return "\n".join([
		"Flipflop Movement Debug",
		"F1: Toggle panel",
		"F2: Cycle preset",
		"",
		"Preset: %s" % state.get("preset", "Unknown"),
		"Linear speed: %.2f" % state.get("linear_speed", 0.0),
		"Angular speed: %.2f" % state.get("angular_speed", 0.0),
		"Grounded: %s" % state.get("grounded", false),
		"Hop cooldown: %.2f" % state.get("hop_cooldown", 0.0),
		"",
		"move_impulse: %.3f" % state.get("move_impulse", 0.0),
		"hop_impulse: %.3f" % state.get("hop_impulse", 0.0),
		"torque_strength: %.3f" % state.get("torque_strength", 0.0),
		"linear_damping: %.2f" % state.get("linear_damping", 0.0),
		"angular_damping: %.2f" % state.get("angular_damping", 0.0),
		"max_linear_speed: %.2f" % state.get("max_linear_speed", 0.0),
		"max_angular_speed: %.2f" % state.get("max_angular_speed", 0.0),
	])
