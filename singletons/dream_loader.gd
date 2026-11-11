extends Node3D

@export var player: Player
@export var fader: ColorRect
@export_range(0.0, 10.0) var fade_time: float = 0.5
var current_dream: Dream
var navigating: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	# TODO: This cannot be the best way to do this
	DataManager.save_loaded.connect(_on_save_loaded)
	if DataManager.save != null: # A save was autoloaded so load it
		_on_save_loaded()
		
func _on_save_loaded():
	navigate_to_dream(DataManager.save.last_link, true)

func _on_navigate_dream(link: DreamLink) -> void:
	if link != null:
		navigate_to_dream(link)
	
func navigate_to_dream(link: DreamLink, skip_fade_in: bool = false):
	if navigating: # If we are already navigating ignore any requests to navigate again
		return 
	navigating = true
	Engine.set_time_scale(1.0)
	get_tree().paused = true
	ResourceLoader.load_threaded_request(link.dream)
	
	# Fade In
	if skip_fade_in:
		fader.color = Color(link.fade_color, 1.0)
	else:
		fader.color = Color(link.fade_color, 0.0)
	fader.visible = true
	var tween = get_tree().create_tween().bind_node(self).set_trans(Tween.TRANS_CUBIC).set_pause_mode(Tween.TWEEN_PAUSE_PROCESS).set_ignore_time_scale(true)
	var fade_in = tween.tween_property(fader, "color:a", 1.0,  fade_time)
	tween.tween_property(fader, "color:a", 0.0,  fade_time)
	await fade_in.finished
	tween.pause()

	# TODO: Make loading dreams better because loading them from disc everytime seems awful???
	if current_dream != null:
		current_dream.queue_free()
	# wait frame to ensure the node has been unloaded before loading next dream
	await get_tree().process_frame
	
	# Update saves information about active link and active dream
	DataManager.save.last_link = link
	
	# Place Player
	player.spawn(link.location, link.pitch, link.yaw, link.scale)
	# Unpause the phyiscs engine to actually move the player before we spawn the new scene in
	set_physics_process(true)
	
	# Get async loaded level and add to node tree
	var packed_dream: PackedScene = ResourceLoader.load_threaded_get(link.dream)
	current_dream = packed_dream.instantiate()
	current_dream.position = Vector3(0.0, 0.0, 0.0)
	add_child(current_dream)
	current_dream.navigate_dream.connect(_on_navigate_dream)
	
	# wait frame to ensure the node has been added to node tree
	await get_tree().process_frame
	get_tree().paused = false 
	
	# Fade Out
	tween.play()
	await tween.finished
	fader.visible = false
	tween.kill()
	
	navigating = false
