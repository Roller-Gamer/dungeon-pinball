@tool
extends Control

@export var item_id := "blast_impact":
	set(value):
		item_id = value
		queue_redraw()

@export var accent_color := Color("f18b45"):
	set(value):
		accent_color = value
		queue_redraw()


func configure(new_item_id: String, new_accent: Color) -> void:
	item_id = new_item_id
	accent_color = new_accent
	queue_redraw()


func _draw() -> void:
	var center := size * 0.5
	match item_id:
		"blast_impact", "blast_damage", "blast_radius", "blast_cooldown", "moving_aftershock":
			_draw_relic(center)
		"throwing_axe", "axe_damage", "axe_count", "axe_cooldown", "returning_axe":
			_draw_axe(center)
		"shield_bash":
			_draw_shield(center + Vector2(-5, 0), 1.55)
			for ray_y in [-18.0, 0.0, 18.0]:
				draw_line(center + Vector2(22, ray_y * 0.62), center + Vector2(42, ray_y), Color("fff1c8"), 4.0, true)
		_:
			_draw_spiked_shield(center)


func _draw_relic(center: Vector2) -> void:
	if item_id == "moving_aftershock":
		for ring_index in 2:
			var ring_center := center + Vector2(-15.0 + float(ring_index) * 30.0, 0.0)
			draw_arc(ring_center, 19.0, 0.0, TAU, 24, accent_color, 4.0, true)
			draw_circle(ring_center, 7.0, Color("fff0a5"))
		draw_line(center + Vector2(-6, -28), center + Vector2(18, -28), Color("fff1c8"), 3.0, true)
		draw_line(center + Vector2(18, -28), center + Vector2(10, -36), Color("fff1c8"), 3.0, true)
		return
	for ray in 10:
		var direction := Vector2.from_angle(TAU * float(ray) / 10.0)
		draw_line(center + direction * 15.0, center + direction * (32.0 + float(ray % 3) * 5.0), accent_color, 6.0, true)
	draw_circle(center, 20.0, Color("fff0a5"))
	draw_circle(center, 10.0, Color("f15c35"))


func _draw_axe(center: Vector2) -> void:
	_draw_axe_shape(center, -0.72, 1.75, Color("ddd5be"))
	if item_id == "returning_axe":
		draw_arc(center, 44.0, -PI * 0.10, PI * 1.30, 24, accent_color, 4.0, true)
		var arrow_tip := center + Vector2.from_angle(PI * 1.30) * 44.0
		draw_line(arrow_tip, arrow_tip + Vector2(13, -2), accent_color, 4.0, true)
		draw_line(arrow_tip, arrow_tip + Vector2(3, 12), accent_color, 4.0, true)


func _draw_axe_shape(center: Vector2, angle: float, icon_scale: float, blade_color: Color) -> void:
	var forward := Vector2.from_angle(angle)
	var side := forward.orthogonal()
	var handle_start := center - forward * 17.0 * icon_scale
	var handle_end := center + forward * 16.0 * icon_scale
	draw_line(handle_start, handle_end, Color("2a1710"), 7.0 * icon_scale, true)
	draw_line(handle_start, handle_end, Color("a66a3e"), 3.5 * icon_scale, true)
	var head_center := center + forward * 11.0 * icon_scale
	var left_blade := PackedVector2Array([
		head_center - forward * 7.0 * icon_scale,
		head_center + side * 5.0 * icon_scale,
		head_center + forward * 8.0 * icon_scale + side * 15.0 * icon_scale,
		head_center + forward * 12.0 * icon_scale + side * 4.0 * icon_scale,
	])
	var right_blade := PackedVector2Array([
		head_center - forward * 7.0 * icon_scale,
		head_center - side * 5.0 * icon_scale,
		head_center + forward * 8.0 * icon_scale - side * 15.0 * icon_scale,
		head_center + forward * 12.0 * icon_scale - side * 4.0 * icon_scale,
	])
	draw_colored_polygon(left_blade, blade_color)
	draw_colored_polygon(right_blade, blade_color.darkened(0.14))
	_draw_closed_polyline(left_blade, Color("fff0c5"), 1.5 * icon_scale)
	_draw_closed_polyline(right_blade, Color("fff0c5"), 1.5 * icon_scale)


func _draw_spiked_shield(center: Vector2) -> void:
	_draw_shield(center, 1.65)
	for spike_angle in [-2.55, -1.85, -1.29, -0.59, 0.24, 0.88, 2.26, 2.90]:
		var spike_direction := Vector2.from_angle(spike_angle)
		draw_line(center + spike_direction * 24.0, center + spike_direction * 38.0, Color("fff1c8"), 4.5, true)


func _draw_shield(center: Vector2, icon_scale: float) -> void:
	var points := PackedVector2Array([
		center + Vector2(-14, -17) * icon_scale,
		center + Vector2(14, -17) * icon_scale,
		center + Vector2(13, 4) * icon_scale,
		center + Vector2(0, 20) * icon_scale,
		center + Vector2(-13, 4) * icon_scale,
	])
	draw_colored_polygon(points, Color(accent_color, 0.72))
	_draw_closed_polyline(points, Color("f4e1aa"), 2.0 * icon_scale)
	draw_line(center + Vector2(0, -13) * icon_scale, center + Vector2(0, 12) * icon_scale, Color("f4e1aa"), 2.0 * icon_scale, true)


func _draw_closed_polyline(points: PackedVector2Array, color: Color, width: float) -> void:
	var closed_points := points.duplicate()
	closed_points.append(points[0])
	draw_polyline(closed_points, color, width, true)
