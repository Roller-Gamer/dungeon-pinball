@tool
extends Line2D

@export var rail_id := "vault_rail"
@export var lock_group := "vault_targets"
@export_range(12.0, 64.0, 1.0) var entrance_radius := 26.0:
	set(value):
		entrance_radius = value
		queue_redraw()
@export_range(200.0, 1200.0, 10.0) var travel_speed := 720.0
@export_range(0.25, 1.5, 0.01) var exit_speed_multiplier := 1.0
@export var accent_color := Color("65d5e8"):
	set(value):
		accent_color = value
		queue_redraw()


func map_data() -> Dictionary:
	var world_points := PackedVector2Array()
	for point in points:
		world_points.append(global_transform * point)
	return {
		"category": "rails",
		"id": rail_id,
		"points": world_points,
		"lock_group": lock_group,
		"entrance_radius": entrance_radius * absf(global_scale.x),
		"travel_speed": travel_speed,
		"exit_speed_multiplier": exit_speed_multiplier,
		"accent_color": accent_color,
		"cooldown": 0.0,
		"unlock_pulse": 0.0,
	}


func _draw() -> void:
	if not Engine.is_editor_hint() or points.size() < 2:
		return
	var entry := points[0]
	var exit := points[points.size() - 1]
	var entry_direction := (points[1] - entry).normalized()
	var exit_direction := (exit - points[points.size() - 2]).normalized()
	draw_circle(entry, entrance_radius, Color(accent_color, 0.13))
	draw_arc(entry, entrance_radius, 0.0, TAU, 32, accent_color, 3.0, true)
	draw_line(entry - entry_direction * 10.0, entry + entry_direction * 13.0, accent_color.lightened(0.25), 4.0, true)
	draw_line(exit - exit_direction * 9.0, exit + exit_direction * 18.0, Color("efbd61"), 4.0, true)
	draw_string(ThemeDB.fallback_font, entry + Vector2(-45.0, 48.0), "RAIL ENTRY", HORIZONTAL_ALIGNMENT_CENTER, 90.0, 11, accent_color)
	draw_string(ThemeDB.fallback_font, exit + Vector2(-38.0, 40.0), "EXIT", HORIZONTAL_ALIGNMENT_CENTER, 76.0, 11, Color("efbd61"))
