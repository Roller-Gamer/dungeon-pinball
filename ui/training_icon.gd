@tool
extends Control

@export var training_id := "sharpened_blade":
	set(value):
		training_id = value
		queue_redraw()

@export var accent_color := Color("e66f4f"):
	set(value):
		accent_color = value
		queue_redraw()


func configure(new_training_id: String, new_accent: Color) -> void:
	training_id = new_training_id
	accent_color = new_accent
	queue_redraw()


func _draw() -> void:
	var center := size * 0.5
	draw_circle(center, 48.0, Color(accent_color, 0.07))
	draw_arc(center, 45.0, 0.0, TAU, 42, Color(accent_color, 0.44), 2.0, true)
	match training_id:
		"sharpened_blade":
			_draw_sword(center)
		"windrunner_boots":
			_draw_boot(center)
		"giants_belt":
			_draw_belt(center)
		"residual_shield":
			_draw_shield(center, true)
		_:
			_draw_shield(center, false)


func _draw_sword(center: Vector2) -> void:
	draw_line(center + Vector2(-20, 26), center + Vector2(16, -20), Color("21140e"), 10.0, true)
	draw_line(center + Vector2(-20, 26), center + Vector2(16, -20), Color("fff1c8"), 6.0, true)
	var blade := PackedVector2Array([
		center + Vector2(10, -17),
		center + Vector2(29, -34),
		center + Vector2(21, -8),
	])
	draw_colored_polygon(blade, accent_color)
	draw_line(center + Vector2(-29, 16), center + Vector2(-9, 32), Color("b9844d"), 7.0, true)


func _draw_boot(center: Vector2) -> void:
	var boot := PackedVector2Array([
		center + Vector2(-15, -27), center + Vector2(6, -27),
		center + Vector2(6, 8), center + Vector2(30, 18),
		center + Vector2(27, 31), center + Vector2(-13, 29),
		center + Vector2(-23, 12),
	])
	draw_colored_polygon(boot, Color(accent_color, 0.82))
	_draw_closed_polyline(boot, Color("fff1c8"), 2.0)
	for streak_y in [-14.0, 0.0, 14.0]:
		draw_line(center + Vector2(-44, streak_y), center + Vector2(-27, streak_y - 4), accent_color, 3.0, true)


func _draw_belt(center: Vector2) -> void:
	draw_line(center + Vector2(-37, 0), center + Vector2(37, 0), Color("321d15"), 24.0, true)
	draw_line(center + Vector2(-35, 0), center + Vector2(35, 0), Color("8b5135"), 17.0, true)
	draw_rect(Rect2(center - Vector2(17, 17), Vector2(34, 34)), accent_color, true)
	draw_rect(Rect2(center - Vector2(10, 10), Vector2(20, 20)), Color("36251b"), true)
	draw_circle(center, 4.0, Color("fff1c8"))


func _draw_shield(center: Vector2, retained: bool) -> void:
	var points := PackedVector2Array([
		center + Vector2(-23, -29), center + Vector2(23, -29),
		center + Vector2(21, 8), center + Vector2(0, 34),
		center + Vector2(-21, 8),
	])
	draw_colored_polygon(points, Color(accent_color, 0.72))
	_draw_closed_polyline(points, Color("f4e1aa"), 3.0)
	draw_line(center + Vector2(0, -23), center + Vector2(0, 23), Color("f4e1aa"), 3.0, true)
	if retained:
		draw_arc(center, 39.0, -PI * 0.15, PI * 1.10, 24, accent_color.lightened(0.25), 4.0, true)
		var tip := center + Vector2.from_angle(PI * 1.10) * 39.0
		draw_line(tip, tip + Vector2(13, -2), accent_color.lightened(0.25), 4.0, true)
		draw_line(tip, tip + Vector2(3, 12), accent_color.lightened(0.25), 4.0, true)


func _draw_closed_polyline(points: PackedVector2Array, color: Color, width: float) -> void:
	var closed_points := points.duplicate()
	closed_points.append(points[0])
	draw_polyline(closed_points, color, width, true)
