@tool
extends Control

signal chosen(index: int)

@export_range(0, 2) var option_index := 0

@onready var spotlight: Polygon2D = %Spotlight
@onready var item_icon: Control = %ItemIcon
@onready var selection_ring: Panel = %SelectionRing
@onready var top_outline: Line2D = %TopOutline
@onready var type_bar: Panel = %TypeBar
@onready var index_badge: Panel = %IndexBadge
@onready var index_label: Label = %IndexLabel
@onready var type_label: Label = %TypeLabel
@onready var item_name_label: Label = %ItemName
@onready var line_one_label: Label = %LineOne
@onready var line_two_label: Label = %LineTwo
@onready var description_tag: Panel = %DescriptionTag
@onready var rank_label: Label = %Rank
@onready var action_label: Label = %Action

var home_position := Vector2.ZERO
var icon_home_position := Vector2.ZERO
var accent := Color("f18b45")
var interactive := true
var hovered := false
var selected := false
var motion_tween: Tween


func _ready() -> void:
	home_position = position
	icon_home_position = item_icon.position
	if Engine.is_editor_hint():
		return
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	gui_input.connect(_on_gui_input)


func configure(index: int, upgrade: Dictionary, upgrade_levels: Dictionary) -> void:
	option_index = index
	accent = Color(String(upgrade.get("color", "f18b45")))
	item_icon.configure(String(upgrade.id), accent)
	index_label.text = "%d" % (index + 1)
	type_label.text = _equipment_offer_label(upgrade)
	item_name_label.text = String(upgrade.name)
	line_one_label.text = String(upgrade.line_1)
	line_two_label.text = String(upgrade.line_2)
	var shown_level := int(upgrade_levels.get(String(upgrade.id), 0)) + 1
	rank_label.text = "NEW EQUIPMENT" if String(upgrade.type).contains("NEW EQUIPMENT") else "RANK %d / %d" % [shown_level, int(upgrade.max_level)]
	_apply_accent()
	reset_state()


func _equipment_offer_label(upgrade: Dictionary) -> String:
	var type_text := String(upgrade.type)
	var slot := "RELIC"
	if type_text.begins_with("WEAPON"):
		slot = "WEAPON"
	elif type_text.begins_with("ARMOR"):
		slot = "ARMOR"
	var treatment := "FORGE UPGRADE"
	if type_text.contains("NEW EQUIPMENT"):
		treatment = "NEW FIND"
	elif type_text.contains("ENCHANTMENT"):
		treatment = "ENCHANTMENT"
	return "%s  •  %s" % [slot, treatment]


func _apply_accent() -> void:
	type_label.add_theme_color_override("font_color", accent)
	rank_label.add_theme_color_override("font_color", accent)
	action_label.add_theme_color_override("font_color", accent)
	index_badge.add_theme_stylebox_override("panel", _accented_style(index_badge, accent))
	type_bar.add_theme_stylebox_override("panel", _accented_style(type_bar, Color(accent, 0.40)))
	description_tag.add_theme_stylebox_override("panel", _accented_style(description_tag, Color(accent, 0.72)))
	selection_ring.add_theme_stylebox_override("panel", _accented_style(selection_ring, Color(accent, 0.82)))
	top_outline.default_color = accent.lightened(0.14)
	spotlight.color = Color(accent, 0.045)


func _accented_style(control: Control, border_color: Color) -> StyleBoxFlat:
	var source := control.get_theme_stylebox("panel")
	var style := source.duplicate() as StyleBoxFlat
	style.border_color = border_color
	return style


func play_entrance(delay: float) -> void:
	visible = true
	position = home_position + Vector2(0, 150)
	modulate = Color(1, 1, 1, 0)
	var entrance := create_tween().set_parallel()
	entrance.tween_property(self, "position", home_position, 0.34).set_delay(delay).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	entrance.tween_property(self, "modulate", Color.WHITE, 0.24).set_delay(delay)


func reset_state() -> void:
	interactive = true
	hovered = false
	selected = false
	modulate = Color.WHITE
	selection_ring.visible = false
	action_label.text = "INSPECT"
	item_icon.position = icon_home_position
	item_icon.scale = Vector2.ONE


func mark_selected(is_selected: bool) -> void:
	interactive = false
	selected = is_selected
	hovered = false
	if is_selected:
		selection_ring.visible = true
		action_label.text = "TAKEN"
		action_label.add_theme_color_override("font_color", Color("fff7d6"))
		_animate_icon(Vector2(0, -10), Vector2.ONE * 1.10)
	else:
		modulate = Color(0.32, 0.32, 0.32, 0.62)


func _on_mouse_entered() -> void:
	if not interactive:
		return
	hovered = true
	selection_ring.visible = true
	action_label.text = "TAKE ITEM"
	_animate_icon(Vector2(0, -7), Vector2.ONE * 1.08)


func _on_mouse_exited() -> void:
	if not interactive:
		return
	hovered = false
	selection_ring.visible = false
	action_label.text = "INSPECT"
	_animate_icon(Vector2.ZERO, Vector2.ONE)


func _on_gui_input(event: InputEvent) -> void:
	if not interactive:
		return
	if event is InputEventScreenTouch:
		var touch_event := event as InputEventScreenTouch
		if touch_event.pressed:
			chosen.emit(option_index)
			accept_event()
		return
	if event is InputEventMouseButton:
		var mouse_event := event as InputEventMouseButton
		if mouse_event.button_index == MOUSE_BUTTON_LEFT and mouse_event.pressed:
			chosen.emit(option_index)
			accept_event()


func _animate_icon(offset: Vector2, target_scale: Vector2) -> void:
	if motion_tween and motion_tween.is_valid():
		motion_tween.kill()
	motion_tween = create_tween().set_parallel()
	motion_tween.tween_property(item_icon, "position", icon_home_position + offset, 0.14).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	motion_tween.tween_property(item_icon, "scale", target_scale, 0.14).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
