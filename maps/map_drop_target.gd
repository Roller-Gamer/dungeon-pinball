@tool
extends Node2D

@export var target_id := "vault_target"
@export var group_id := "vault_targets"
@export_range(12.0, 60.0, 1.0) var half_width := 24.0:
	set(value):
		half_width = value
		queue_redraw()
@export_range(4.0, 24.0, 1.0) var thickness := 12.0:
	set(value):
		thickness = value
		queue_redraw()
@export_range(1, 5, 1) var required_hits := 1
@export_range(0.0, 1.2, 0.01) var restitution := 0.78
@export var accent_color := Color("d95249"):
	set(value):
		accent_color = value
		queue_redraw()


func map_data() -> Dictionary:
	return {
		"category": "drop_targets",
		"id": target_id,
		"group_id": group_id,
		"pos": global_position,
		"angle": global_rotation,
		"half_width": half_width * absf(global_scale.x),
		"thickness": thickness * absf(global_scale.y),
		"required_hits": required_hits,
		"hits_remaining": required_hits,
		"restitution": restitution,
		"accent_color": accent_color,
		"down": false,
		"cooldown": 0.0,
		"pulse": 0.0,
		"drop_progress": 0.0,
	}


func _draw() -> void:
	if not Engine.is_editor_hint():
		return
	var rect := Rect2(Vector2(-half_width, -thickness * 0.5), Vector2(half_width * 2.0, thickness))
	draw_rect(rect.grow(5.0), Color("0d0907"), true)
	draw_rect(rect, Color("68402a"), true)
	draw_rect(rect, accent_color, false, 3.0)
	draw_circle(Vector2(-half_width + 7.0, 0.0), 2.5, Color("efbd61"))
	draw_circle(Vector2(half_width - 7.0, 0.0), 2.5, Color("efbd61"))
	draw_string(ThemeDB.fallback_font, Vector2(-half_width, thickness + 16.0), target_id.to_upper(), HORIZONTAL_ALIGNMENT_CENTER, half_width * 2.0, 10, accent_color)
