extends Control

# Standalone scenery select screen from the main menu.
# Scenery buttons start the normal gameplay scene and pass the requested
# scenery ID to SceneryManager3D through SceneTree metadata.

const SCENERY_DESCRIPTIONS := {
	"deserted_island": "Sand, coconuts, crabs, and existential loneliness.",
	"resort_pool": "Slippery tiles, pool toys, and vacation chaos.",
	"boardwalk": "Wood planks, trash cans, gulls, and beach-town clutter.",
	"cruise_ship_deck": "Wind, railings, pool floats, and bad decisions.",
	"locker_room": "Wet tiles, drains, soap bottles, and questionable hygiene.",
}


func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	_build_ui()


func _unhandled_input(event: InputEvent) -> void:
	var key_event: InputEventKey = event as InputEventKey
	if key_event == null or not key_event.pressed or key_event.echo:
		return

	if key_event.keycode == KEY_ESCAPE:
		_on_back_pressed()
		get_viewport().set_input_as_handled()


func _build_ui() -> void:
	var shade: ColorRect = _make_background()
	add_child(shade)

	var panel: PanelContainer = _make_panel()
	add_child(panel)

	var list: VBoxContainer = _make_list(panel)
	_add_title(list, "Choose Scenery")
	_add_scenery_button(list, FlipflopUIManager.DESERTED_ISLAND_ID)
	_add_scenery_button(list, FlipflopUIManager.RESORT_POOL_ID)
	_add_scenery_button(list, FlipflopUIManager.BOARDWALK_ID)
	_add_scenery_button(list, FlipflopUIManager.CRUISE_SHIP_DECK_ID)
	_add_scenery_button(list, FlipflopUIManager.LOCKER_ROOM_ID)
	_add_spacer(list, 8.0)
	_add_button(list, "Back", _on_back_pressed)


func _make_background() -> ColorRect:
	return FlipflopUIStyle.make_background()


func _make_panel() -> PanelContainer:
	var panel := PanelContainer.new()
	panel.anchor_left = 0.5
	panel.anchor_right = 0.5
	panel.anchor_top = 0.5
	panel.anchor_bottom = 0.5
	panel.offset_left = -330.0
	panel.offset_right = 330.0
	panel.offset_top = -330.0
	panel.offset_bottom = 330.0
	FlipflopUIStyle.apply_panel(panel)
	return panel


func _make_list(panel: PanelContainer) -> VBoxContainer:
	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 24)
	margin.add_theme_constant_override("margin_right", 24)
	margin.add_theme_constant_override("margin_top", 24)
	margin.add_theme_constant_override("margin_bottom", 24)
	panel.add_child(margin)

	var list := VBoxContainer.new()
	list.add_theme_constant_override("separation", 12)
	margin.add_child(list)
	return list


func _add_title(list: VBoxContainer, text: String) -> void:
	var label := Label.new()
	label.text = text
	FlipflopUIStyle.style_title(label)
	list.add_child(label)
	_add_spacer(list, 6.0)


func _add_scenery_button(list: VBoxContainer, scenery_id: String) -> void:
	var label: String = FlipflopUIManager.get_scenery_display_name(scenery_id)
	var button: Button = _add_button(list, label, _on_scenery_pressed.bind(scenery_id))
	button.tooltip_text = "Start in %s" % label
	var description := Label.new()
	description.text = String(SCENERY_DESCRIPTIONS.get(scenery_id, "Another place to be a lost flipflop."))
	description.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	FlipflopUIStyle.style_muted(description)
	list.add_child(description)


func _add_button(list: VBoxContainer, text: String, callback: Callable) -> Button:
	var button := Button.new()
	button.text = text
	FlipflopUIStyle.apply_button(button)
	button.pressed.connect(callback)
	list.add_child(button)
	return button


func _add_spacer(list: VBoxContainer, height: float) -> void:
	var spacer := Control.new()
	spacer.custom_minimum_size = Vector2(0.0, height)
	list.add_child(spacer)


func _on_scenery_pressed(scenery_id: String) -> void:
	FlipflopUIManager.load_game(get_tree(), scenery_id)


func _on_back_pressed() -> void:
	get_tree().change_scene_to_file(FlipflopUIManager.MAIN_MENU_SCENE_PATH)
