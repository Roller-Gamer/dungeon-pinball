@tool
extends Control

signal chosen(index: int)

@export_range(0, 2) var option_index := 0

@onready var card_frame: Panel = %CardFrame
@onready var inner_frame: Panel = %InnerFrame
@onready var selection_glow: Panel = %SelectionGlow
@onready var top_stripe: ColorRect = %TopStripe
@onready var index_badge: Panel = %IndexBadge
@onready var index_label: Label = %IndexLabel
@onready var type_label: Label = %TypeLabel
@onready var training_icon: Control = %TrainingIcon
@onready var name_label: Label = %TrainingName
@onready var divider: ColorRect = %Divider
@onready var line_one_label: Label = %LineOne
@onready var line_two_label: Label = %LineTwo
@onready var rank_label: Label = %Rank
@onready var action_panel: Panel = %ActionPanel
@onready var action_label: Label = %Action
@onready var resting_action_label: Label = %RestingAction

var home_position := Vector2.ZERO
var accent := Color("e66f4f")
var interactive := true
var selected := false
var motion_tween: Tween


func _ready() -> void:
	home_position = position
	pivot_offset = size * 0.5
	if Engine.is_editor_hint():
		return
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	gui_input.connect(_on_gui_input)


func configure(index: int, training: Dictionary, upgrade_levels: Dictionary) -> void:
	option_index = index
	accent = Color(String(training.get("color", "e66f4f")))
	index_label.text = "%d" % (index + 1)
	type_label.text = String(training.type)
	training_icon.configure(String(training.id), accent)
	name_label.text = String(training.name)
	line_one_label.text = String(training.line_1)
	line_two_label.text = String(training.line_2)
	var shown_level := int(upgrade_levels.get(String(training.id), 0)) + 1
	rank_label.text = "TRAINING LEVEL %d / %d" % [shown_level, int(training.max_level)]
	_apply_accent()
	reset_state()


func _apply_accent() -> void:
	type_label.add_theme_color_override("font_color", accent)
	rank_label.add_theme_color_override("font_color", accent)
	action_label.add_theme_color_override("font_color", accent)
	top_stripe.color = accent
	divider.color = Color(accent, 0.50)
	card_frame.add_theme_stylebox_override("panel", _accented_style(card_frame, Color(accent, 0.76)))
	index_badge.add_theme_stylebox_override("panel", _accented_style(index_badge, accent))
	action_panel.add_theme_stylebox_override("panel", _accented_style(action_panel, Color(accent, 0.64)))
	selection_glow.add_theme_stylebox_override("panel", _accented_style(selection_glow, Color(accent.lightened(0.20), 0.92)))


func _accented_style(control: Control, border_color: Color) -> StyleBoxFlat:
	var style := control.get_theme_stylebox("panel").duplicate() as StyleBoxFlat
	style.border_color = border_color
	return style


func play_entrance(delay: float) -> void:
	visible = true
	position = home_position + Vector2(0, 150)
	modulate = Color(1, 1, 1, 0)
	scale = Vector2(0.96, 0.96)
	var entrance := create_tween().set_parallel()
	entrance.tween_property(self, "position", home_position, 0.34).set_delay(delay).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	entrance.tween_property(self, "modulate", Color.WHITE, 0.24).set_delay(delay)
	entrance.tween_property(self, "scale", Vector2.ONE, 0.30).set_delay(delay).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)


func reset_state() -> void:
	interactive = true
	selected = false
	modulate = Color.WHITE
	scale = Vector2.ONE
	selection_glow.visible = false
	action_panel.visible = false
	resting_action_label.visible = true
	action_label.text = "CHOOSE"


func mark_selected(is_selected: bool) -> void:
	interactive = false
	selected = is_selected
	if is_selected:
		selection_glow.visible = true
		action_panel.visible = true
		resting_action_label.visible = false
		action_label.text = "TRAINING CHOSEN"
		action_label.add_theme_color_override("font_color", Color("fff7d6"))
		_animate_scale(Vector2(1.035, 1.035))
	else:
		modulate = Color(0.30, 0.30, 0.30, 0.60)


func _on_mouse_entered() -> void:
	if not interactive:
		return
	selection_glow.visible = true
	action_panel.visible = true
	resting_action_label.visible = false
	action_label.text = "BEGIN TRAINING"
	_animate_scale(Vector2(1.025, 1.025))


func _on_mouse_exited() -> void:
	if not interactive:
		return
	selection_glow.visible = false
	action_panel.visible = false
	resting_action_label.visible = true
	action_label.text = "CHOOSE"
	_animate_scale(Vector2.ONE)


func _on_gui_input(event: InputEvent) -> void:
	if not interactive:
		return
	if event is InputEventMouseButton:
		var mouse_event := event as InputEventMouseButton
		if mouse_event.button_index == MOUSE_BUTTON_LEFT and mouse_event.pressed:
			chosen.emit(option_index)
			accept_event()


func _animate_scale(target_scale: Vector2) -> void:
	if motion_tween and motion_tween.is_valid():
		motion_tween.kill()
	motion_tween = create_tween()
	motion_tween.tween_property(self, "scale", target_scale, 0.14).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
