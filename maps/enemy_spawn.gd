@tool
extends Node2D

@export_enum("grunt", "soldier", "mage", "orc", "boss") var enemy_kind := "grunt":
	set(value):
		enemy_kind = value
		queue_redraw()
@export_range(10.0, 100.0, 1.0) var radius := 25.0:
	set(value):
		radius = value
		queue_redraw()
@export_range(1, 500, 1) var base_hp := 20
@export var objective_target := false
@export var is_warlord := false
@export_range(-1, 3, 1) var guard_slot := -1


func map_data() -> Dictionary:
	return {
		"category": "enemies",
		"id": name.to_snake_case(),
		"pos": global_position,
		"radius": radius * absf(global_scale.x),
		"base_hp": base_hp,
		"kind": enemy_kind,
		"objective_target": objective_target,
		"is_warlord": is_warlord,
		"guard_slot": guard_slot,
	}


func _draw() -> void:
	if not Engine.is_editor_hint():
		return
	var color := Color("b84b3f")
	match enemy_kind:
		"mage":
			color = Color("b77be8")
		"soldier":
			color = Color("d06449")
		"orc":
			color = Color("d29a4a")
		"boss":
			color = Color("efbd61")
	draw_circle(Vector2.ZERO, radius, Color(color, 0.20))
	draw_arc(Vector2.ZERO, radius, 0, TAU, 40, color, 3.0, true)
	if objective_target:
		draw_arc(Vector2.ZERO, radius + 6.0, 0, TAU, 40, Color("fff1c8"), 2.0, true)
	draw_line(Vector2(-radius * 0.55, 0), Vector2(radius * 0.55, 0), color, 2.0, true)
	draw_line(Vector2(0, -radius * 0.55), Vector2(0, radius * 0.55), color, 2.0, true)
	draw_string(ThemeDB.fallback_font, Vector2(-radius, radius + 15), enemy_kind.to_upper(), HORIZONTAL_ALIGNMENT_CENTER, radius * 2.0, 10, color)
