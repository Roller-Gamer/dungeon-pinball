@tool
extends Node2D

@export_range(20.0, 240.0, 1.0) var half_length := 112.0:
	set(value):
		half_length = value
		queue_redraw()
@export_range(4.0, 50.0, 1.0) var thickness := 22.0:
	set(value):
		thickness = value
		queue_redraw()
@export_range(-3.0, 3.0, 0.01) var angular_speed := 0.42
@export_range(0.0, 1.2, 0.01) var restitution := 0.78


func map_data() -> Dictionary:
	return {
		"category": "rotors",
		"id": name.to_snake_case(),
		"pos": global_position,
		"half_length": half_length * absf(global_scale.x),
		"thickness": thickness * absf(global_scale.y),
		"angle": global_rotation,
		"angular_speed": angular_speed,
		"restitution": restitution,
		"pulse": 0.0,
	}


func _draw() -> void:
	if not Engine.is_editor_hint():
		return
	var start := Vector2(-half_length, 0)
	var finish := Vector2(half_length, 0)
	draw_arc(Vector2.ZERO, half_length, 0, TAU, 64, Color("a8793b", 0.30), 2.0, true)
	draw_line(start, finish, Color("0d0907"), thickness + 10.0, true)
	draw_line(start, finish, Color("a8793b"), thickness, true)
	draw_line(start, finish, Color("68402a"), maxf(2.0, thickness - 8.0), true)
	draw_circle(Vector2.ZERO, 15.0, Color("c4924d"))
