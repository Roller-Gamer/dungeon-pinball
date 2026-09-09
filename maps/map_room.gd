@tool
extends Node2D

@export var layout_id := "classic"
@export var status_text := "STAGE 1-1"
@export_enum("purge", "target") var objective_mode := "target"
@export var objective_title := "DEFEAT THE ELITE"


func collect_room_data() -> Dictionary:
	var room_data := {
		"layout_id": layout_id,
		"status_text": status_text,
		"objective_mode": objective_mode,
		"objective_title": objective_title,
		"walls": [],
		"diamonds": [],
		"rotors": [],
		"rails": [],
		"drop_targets": [],
		"combat_runes": [],
		"fury_skills": [],
		"enemies": [],
	}
	_collect_elements(self, room_data)
	return room_data


func _collect_elements(parent: Node, room_data: Dictionary) -> void:
	for child in parent.get_children():
		if child.has_method("map_data"):
			var element: Dictionary = child.map_data()
			var category := String(element.get("category", ""))
			element.erase("category")
			if room_data.has(category):
				room_data[category].append(element)
		_collect_elements(child, room_data)


func _draw() -> void:
	if not Engine.is_editor_hint():
		return
	var playfield := Rect2(350.0, 32.0, 740.0, 854.0)
	draw_rect(playfield, Color("65d5e8", 0.10), false, 2.0)
	draw_line(Vector2(645, 48), Vector2(795, 48), Color("efbd61", 0.72), 5.0, true)
	draw_line(Vector2(550, 570), Vector2(890, 570), Color("d1b77e", 0.42), 2.0, true)
	draw_string(ThemeDB.fallback_font, Vector2(656, 28), "EXIT", HORIZONTAL_ALIGNMENT_LEFT, -1.0, 12, Color("efbd61"))
	draw_string(ThemeDB.fallback_font, Vector2(650, 594), "LAUNCH HEIGHT", HORIZONTAL_ALIGNMENT_LEFT, -1.0, 11, Color("d1b77e", 0.72))
