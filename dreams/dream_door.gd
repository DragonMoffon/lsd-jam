class_name DreamDoor
extends Area3D

@export_category("Link Details")
@export var link: DreamLink
@export var is_touchable: bool = true
@export var is_interactable: bool = true

@export_category("Weight Adjustment")
@export_enum("Add", "Mulitply", "Set") var change_method: int = 0
@export var integrity_change: float = 0.0
@export var lucidity_change: float = 0.0

signal navigate_dream(link: DreamLink)

func interact():
	if is_interactable:
		navigate()
		
func touch(_body: Node3D): # The door has a mask of just the player layer so this should be fine
	if is_touchable:
		navigate()
		
func navigate(apply_weights: bool = true):
	if is_queued_for_deletion():
		return
	if apply_weights:
		DataManager.save.update_weights(link.change_method, link.integrity_change, link.lucidity_change)
		DataManager.save.update_weights(change_method, integrity_change, lucidity_change)
	navigate_dream.emit(link)
