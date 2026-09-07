@tool
extends Control

signal item_chosen(index: int)

@onready var heading_label: Label = %Heading
@onready var subtitle_label: Label = %Subtitle
@onready var offers: Array[Control] = [%OfferOne, %OfferTwo, %OfferThree]


func _ready() -> void:
	if Engine.is_editor_hint():
		return
	for offer in offers:
		offer.chosen.connect(_on_offer_chosen)
	hide_selection()


func present(choices: Array[Dictionary], upgrade_levels: Dictionary, stage_room: int, room_clear_pending: bool, last_room_heal: int) -> void:
	heading_label.text = "STAGE  1-%d  CLEARED  •  TREASURE VAULT" % stage_room
	var rest_text := "TREASURE FOUND"
	if room_clear_pending:
		rest_text = "REST +%d HP" % last_room_heal if last_room_heal > 0 else "REST • HEALTH FULL"
	subtitle_label.text = "One prize may leave the vault with you  •  %s  •  NEXT: STAGE 1-%d" % [rest_text, stage_room + 1]
	visible = true
	mouse_filter = Control.MOUSE_FILTER_STOP
	for index in offers.size():
		var offer := offers[index]
		if index < choices.size():
			offer.visible = true
			offer.configure(index, choices[index], upgrade_levels)
			offer.play_entrance(float(index) * 0.10)
		else:
			offer.visible = false


func mark_selected(index: int) -> void:
	for offer_index in offers.size():
		if offers[offer_index].visible:
			offers[offer_index].mark_selected(offer_index == index)


func hide_selection() -> void:
	visible = false
	mouse_filter = Control.MOUSE_FILTER_IGNORE


func _on_offer_chosen(index: int) -> void:
	item_chosen.emit(index)
