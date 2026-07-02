class_name FlipflopUIStyle
extends RefCounted

# Shared styling helpers for Flipflop Island menus.
# Keeping these values in one place makes temporary prototype menus feel like
# one game without introducing a full custom Theme resource yet.

const PANEL_COLOR := Color(0.02, 0.035, 0.035, 0.76)
const PANEL_BORDER := Color(0.88, 0.76, 0.54, 0.38)
const BUTTON_NORMAL := Color(0.28, 0.19, 0.105, 0.88)
const BUTTON_HOVER := Color(0.38, 0.27, 0.15, 0.94)
const BUTTON_PRESSED := Color(0.18, 0.12, 0.07, 0.96)
const BUTTON_FOCUS := Color(0.47, 0.34, 0.18, 0.96)
const TEXT_PRIMARY := Color(0.96, 0.91, 0.78)
const TEXT_BODY := Color(0.91, 0.96, 0.9)
const TEXT_MUTED := Color(0.72, 0.86, 0.78)


static func apply_button(button: Button, min_height: float = 44.0) -> void:
	button.custom_minimum_size = Vector2(0.0, min_height)
	button.focus_mode = Control.FOCUS_ALL
	button.add_theme_font_size_override("font_size", 17)
	button.add_theme_color_override("font_color", Color(1.0, 0.94, 0.82))
	button.add_theme_color_override("font_hover_color", Color(1.0, 0.98, 0.88))
	button.add_theme_color_override("font_focus_color", Color(1.0, 0.98, 0.88))
	button.add_theme_color_override("font_pressed_color", Color(0.95, 0.86, 0.68))
	button.add_theme_stylebox_override("normal", make_button_style(BUTTON_NORMAL))
	button.add_theme_stylebox_override("hover", make_button_style(BUTTON_HOVER))
	button.add_theme_stylebox_override("pressed", make_button_style(BUTTON_PRESSED))
	button.add_theme_stylebox_override("focus", make_button_style(BUTTON_FOCUS, true))


static func apply_panel(panel: PanelContainer, alpha: float = 0.76) -> void:
	panel.add_theme_stylebox_override("panel", make_panel_style(alpha))


static func style_title(label: Label, size: int = 30) -> void:
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", size)
	label.add_theme_color_override("font_color", TEXT_PRIMARY)
	label.add_theme_color_override("font_shadow_color", Color(0.0, 0.0, 0.0, 0.78))
	label.add_theme_constant_override("shadow_offset_x", 2)
	label.add_theme_constant_override("shadow_offset_y", 2)


static func style_section(label: Label) -> void:
	label.add_theme_font_size_override("font_size", 18)
	label.add_theme_color_override("font_color", TEXT_PRIMARY)


static func style_body(control: Control, size: int = 17) -> void:
	control.add_theme_font_size_override("font_size", size)
	control.add_theme_color_override("font_color", TEXT_BODY)


static func style_muted(label: Label, size: int = 14) -> void:
	label.add_theme_font_size_override("font_size", size)
	label.add_theme_color_override("font_color", TEXT_MUTED)


static func make_background() -> ColorRect:
	var shade := ColorRect.new()
	shade.set_anchors_preset(Control.PRESET_FULL_RECT)
	shade.color = Color(0.025, 0.065, 0.07, 1.0)
	return shade


static func make_panel_style(alpha: float = 0.76) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(PANEL_COLOR.r, PANEL_COLOR.g, PANEL_COLOR.b, alpha)
	style.border_color = PANEL_BORDER
	style.set_border_width_all(1)
	style.set_corner_radius_all(8)
	style.shadow_color = Color(0.0, 0.0, 0.0, 0.38)
	style.shadow_size = 8
	return style


static func make_button_style(color: Color, focused: bool = false) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = color
	style.border_color = Color(0.92, 0.78, 0.5, 0.5 if focused else 0.36)
	style.set_border_width_all(2 if focused else 1)
	style.set_corner_radius_all(6)
	style.content_margin_left = 10.0
	style.content_margin_right = 10.0
	return style
