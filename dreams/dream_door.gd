class_name DreamDoor
extends Area3D

@export var link: DreamLink
@export var is_touchable: bool = true
@export var is_interactable: bool = true

signal navigate_dream(link: DreamLink)

func interact():
	if is_interactable:
		navigate_dream.emit(link)
		
func touch(_body: Node3D): # The door has a mask of just the player layer so this should be fine
	if is_touchable:
		navigate_dream.emit(link)
		
