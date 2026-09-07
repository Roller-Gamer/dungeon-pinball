@tool
extends Control

signal training_chosen(index: int)

@onready var heading_label: Label = %Heading
@onready var subtitle_label: Label = %Subtitle
@onready var cards: Array[Control] = [%CardOne, %CardTwo, %CardThree]


func _ready() -> void:
	if Engine.is_editor_hint():
		return
	for card in cards:
		card.chosen.connect(_on_card_chosen)
	hide_selection()


func present(choices: Array[Dictionary], upgrade_levels: Dictionary, hero_level: int, pending_level_ups: int, room_clear_pending: bool, last_room_heal: int) -> void:
	heading_label.text = "WARRIOR LEVEL  %d  •  TRAINING HALL" % hero_level
	var rest_text := "TRAINING EARNED IN BATTLE"
	if room_clear_pending:
		rest_text = "REST +%d HP" % last_room_heal if last_room_heal > 0 else "REST • HEALTH FULL"
	var remaining_text := "  •  %d TRAINING LEFT" % pending_level_ups if pending_level_ups > 1 else ""
	subtitle_label.text = "Strengthen the warrior's base abilities  •  %s%s" % [rest_text, remaining_text]
	visible = true
	mouse_filter = Control.MOUSE_FILTER_STOP
	for index in cards.size():
		var card := cards[index]
		if index < choices.size():
			card.visible = true
			card.configure(index, choices[index], upgrade_levels)
			card.play_entrance(float(index) * 0.10)
		else:
			card.visible = false


func mark_selected(index: int) -> void:
	for card_index in cards.size():
		if cards[card_index].visible:
			cards[card_index].mark_selected(card_index == index)


func hide_selection() -> void:
	visible = false
	mouse_filter = Control.MOUSE_FILTER_IGNORE


func _on_card_chosen(index: int) -> void:
	training_chosen.emit(index)
