@tool
extends Node2D

@export_range(8.0, 120.0, 1.0) var half_diagonal := 34.0:
	set(value):
		half_diagonal = value
		queue_redraw()
@export_range(2.0, 40.0, 1.0) var thickness := 10.0
@export_range(0.0, 1.2, 0.01) var restitution := 0.92


func map_data() -> Dictionary:
	return {
		"category": "diamonds",
		"id": name.to_snake_case(),
		"pos": global_position,
		"half_diagonal": half_diagonal * absf(global_scale.x),
		"thickness": thickness,
		"restitution": restitution,
		"cooldown": 0.0,
		"pulse": 0.0,
	}


func _draw() -> void:
	if not Engine.is_editor_hint():
		return
	var points := PackedVector2Array([
		Vector2(0, -half_diagonal), Vector2(half_diagonal, 0),
		Vector2(0, half_diagonal), Vector2(-half_diagonal, 0),
	])
	draw_colored_polygon(points, Color("3d4540"))
	var closed := points.duplicate()
	closed.append(points[0])
	draw_polyline(closed, Color("e2b56b"), 3.0, true)
