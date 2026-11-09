class_name DreamDoor
extends StaticBody3D

@export var link: DreamLink
signal navigate_dream(link: DreamLink)

func interact():
	navigate_dream.emit(link)
