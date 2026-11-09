extends Node3D

@export var initial_link: DreamLink
@export var player: Player
@export var fader: ColorRect
var current_dream: Dream

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	if initial_link != null:
		navigate_to_dream(initial_link)

func _on_navigate_dream(link: DreamLink) -> void:
	if link != null:
		navigate_to_dream(link)
	
func navigate_to_dream(link: DreamLink):
	player.spawn(link.location, link.pitch, link.yaw, link.scale)
	
	# TODO: Make loading dreams better because loading them from disc everytime seems aweful???
	if current_dream != null:
		current_dream.queue_free()

	var packed_dream: PackedScene = load(link.dream)
	current_dream = packed_dream.instantiate()
	current_dream.position = Vector3(0.0, 0.0, 0.0)
	add_child(current_dream)
	current_dream.navigate_dream.connect(_on_navigate_dream)
