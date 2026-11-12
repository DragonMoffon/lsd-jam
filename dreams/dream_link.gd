class_name DreamLink
extends Resource

@export_category("Link Location")
@export var name: String
@export_color_no_alpha var fade_color: Color
@export_file("*.tscn","*.scn") var dream: String
@export var location: Vector3 = Vector3(0.0, 0.0, 0.0)
@export_range(-89, 89) var pitch: float = 0.0
@export_range(-180, 180) var yaw: float = 0.0
@export_range(0, 2) var scale: float = 1.0

@export var weight_modifiers: WeightModifiers = preload("res://dreams/default_dream_weight_modifiers.tres")
