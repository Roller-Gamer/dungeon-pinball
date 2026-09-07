@tool
extends Node2D

@export var end_offset := Vector2(100.0, 0.0):
	set(value):
		end_offset = value
		queue_redraw()
@export_range(0.0, 1.0, 0.01) var friction := 0.015
@export var kick := 0.0


func map_data() -> Dictionary:
	return {
		"category": "walls",
		"id": name.to_snake_case(),
		"a": global_transform * Vector2.ZERO,
		"b": global_transform * end_offset,
		"friction": friction,
		"kick": kick,
	}


func _draw() -> void:
	if not Engine.is_editor_hint():
		return
	draw_line(Vector2.ZERO, end_offset, Color("0d0907", 0.82), 27.0, true)
	draw_line(Vector2.ZERO, end_offset, Color("a8793b"), 20.0, true)
	draw_line(Vector2.ZERO, end_offset, Color("68402a"), 13.0, true)
	draw_line(Vector2.ZERO, end_offset, Color("b98750"), 3.0, true)
	draw_circle(Vector2.ZERO, 5.0, Color("d2a85d"))
	draw_circle(end_offset, 5.0, Color("d2a85d"))
