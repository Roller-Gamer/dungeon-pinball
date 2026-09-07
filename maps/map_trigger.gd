@tool
extends Node2D

@export_enum("combat_rune", "fury_skill") var trigger_type := "combat_rune":
	set(value):
		trigger_type = value
		queue_redraw()
@export var trigger_id := "momentum":
	set(value):
		trigger_id = value
		queue_redraw()
@export var display_name := "MOMENTUM  +30%"
@export_range(8.0, 80.0, 1.0) var radius := 22.0:
	set(value):
		radius = value
		queue_redraw()
@export_range(8.0, 100.0, 1.0) var visual_radius := 27.0:
	set(value):
		visual_radius = value
		queue_redraw()
@export var accent_color := Color("65d5e8"):
	set(value):
		accent_color = value
		queue_redraw()
@export var implemented := true
@export_range(0.0, 20.0, 0.1) var activation_cooldown := 3.0


func map_data() -> Dictionary:
	var category := "combat_runes" if trigger_type == "combat_rune" else "fury_skills"
	var data := {
		"category": category,
		"id": trigger_id,
		"name": display_name,
		"pos": global_position,
		"radius": radius * absf(global_scale.x),
		"color": accent_color,
		"cooldown": 0.0,
		"pulse": 0.0,
		"inside": false,
	}
	if trigger_type == "combat_rune":
		data.visual_radius = visual_radius * absf(global_scale.x)
		data.implemented = implemented
		data.activation_cooldown = activation_cooldown
	return data


func _draw() -> void:
	if not Engine.is_editor_hint():
		return
	var shown_radius := visual_radius if trigger_type == "combat_rune" else radius
	draw_circle(Vector2.ZERO, shown_radius, Color(accent_color, 0.16))
	draw_arc(Vector2.ZERO, shown_radius, 0, TAU, 36, accent_color, 3.0, true)
	draw_line(Vector2(-8, 0), Vector2(8, 0), accent_color.lightened(0.35), 3.0, true)
	draw_line(Vector2(0, -8), Vector2(0, 8), accent_color.lightened(0.35), 3.0, true)
	draw_string(ThemeDB.fallback_font, Vector2(-shown_radius, shown_radius + 16), trigger_id.to_upper(), HORIZONTAL_ALIGNMENT_CENTER, shown_radius * 2.0, 10, accent_color)
