class_name DreamDoor
extends Area3D

@export_category("Link Details")
@export var link: DreamLink
@export var is_touchable: bool = true
@export var is_interactable: bool = true
@export var weight_modifiers: WeightModifiers = preload("res://dreams/default_dream_weight_modifiers.tres")

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
		DataManager.update_weights(link.weight_modifiers, weight_modifiers)
	navigate_dream.emit(link)
