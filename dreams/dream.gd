class_name Dream
extends Node3D

signal navigate_dream(link: DreamLink)

func _on_navigate_dream(link: DreamLink) -> void:
	navigate_dream.emit(link)
