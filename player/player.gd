class_name Player
extends CharacterBody3D


@export var camera: Camera3D
@export var cursor: Sprite2D
@export var collider: CapsuleShape3D
@export_range(0.0, 2.0) var look_sensitivity: float = 1.0
@export_range(0.0, 180.0) var focus_yaw_range: float = 15.0
@export_range(0.0, 90.0) var focus_pitch_range: float = 15.0

const FOV_MOVE := 75.0 # Field of view when moving around normally
const FOV_FOCUS := 60.0 # Field of view when focusing/looking around
const SPEED := 5.0 # Base player speed
const SPRINT_SPEED := 15.0 # Sprinting player speed
const SPRINT_BUFFER := 320 # ms in which a double forward tap starts sprinting
const LOOK_DELAY := 100 # ms after which the player's focus will center on the cursor
const LOOK_SPEED := 0.5 # Base mouse sensitivity of the plater
const FOCUS_TIMESCALE := 0.05 # How much time should slow when the player is focusing # TODO: Audio timescale (slowing?)
const BASE_TIMESCALE := 1.0 # The base speed rate (always 1.0 basically)
const TRANSITION_LENGTH := 0.25 # Number of seconds it should take to go from moving -> focus and back
const TIMESCALE_DELTA := abs(FOCUS_TIMESCALE - BASE_TIMESCALE) / TRANSITION_LENGTH
const FOV_DELTA := abs(FOV_FOCUS - FOV_MOVE) / TRANSITION_LENGTH

var sprint_time := 0.0 # Time tracker using SPRINT_BUFFER to decide if should sprint
var is_foward_sprinting := false # Is the player sprinting because they double tapped forward?
var look_direction := Vector2(0.0, 0.0) # What are the angles the player's camera should use
var focus_look_time := 0.0 # When should the player camera start moving to look
var focus_target := Vector2(0.0, 0.0) # What location should the player focus on
var is_on_ground_or_slope := true

func spawn(new_location: Vector3, new_pitch: float = 0.0, new_yaw: float = 0.0):
	cursor.position = Vector2(0.0, 0.0)
	sprint_time = Time.get_ticks_msec()
	focus_look_time = sprint_time
	
	position = new_location
	look_direction = Vector2(new_pitch, new_yaw) # TODO: handle player being rotated
	camera.rotation_degrees.x = look_direction.x
	camera.rotation_degrees.y = look_direction.y
	camera.rotation_degrees.z = 0.0
	
	# TODO: set player scale based on savedata and player's move speed
	# camera.position.y = 0.8 * new_scale
	# collider.height = 2 * new_scale
	# collider.radius = 0.5 * new_scale
	
	# Force the player's phyiscs transform to sync with their node transform.
	# If this isn't done there will be a frame of any new dream where they will
	# still be at their old location.
	PhysicsServer3D.body_set_mode(get_rid(), PhysicsServer3D.BODY_MODE_STATIC)
	force_update_transform()
	PhysicsServer3D.body_set_mode(get_rid(), PhysicsServer3D.BODY_MODE_KINEMATIC)

func _process_move(delta: float):
	var true_delta = delta / Engine.get_time_scale()
	Engine.set_time_scale(move_toward(Engine.get_time_scale(), BASE_TIMESCALE, TIMESCALE_DELTA * true_delta))
	cursor.position = Util.smerp2d(cursor.position, Vector2(0.0, 0.0), true_delta,  0.01)
	
	# Camera look code
	camera.fov = move_toward(camera.fov, FOV_MOVE, FOV_DELTA * true_delta)
	var resolution : Vector2 = get_viewport().size / 2.0
	var mouse_offset : Vector2 = cursor.position / resolution
	camera.rotation_degrees.x = look_direction.x - clampf(mouse_offset.y, -1.0, 1.0) * focus_pitch_range
	camera.rotation_degrees.y = look_direction.y - clampf(mouse_offset.x, -1.0, 1.0) * focus_yaw_range
	
	# Movement code
	var input_dir := Input.get_vector("left", "right", "forward", "backwards")
	var is_sprinting := (Input.is_action_pressed("sprint") or is_foward_sprinting) and Input.is_action_pressed("forward")
	var speed := SPRINT_SPEED if is_sprinting else SPEED
	var direction := (camera.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)
	
func _focus_look_towards(true_delta: float):	
	var resolution : Vector2 = get_viewport().size / 2.0
	var mouse_offset : Vector2 = cursor.position / resolution
	camera.rotation_degrees.x = look_direction.x - clampf(mouse_offset.y, -1.0, 1.0) * focus_pitch_range
	camera.rotation_degrees.y = look_direction.y - clampf(mouse_offset.x, -1.0, 1.0) * focus_yaw_range
	
	return
	var target: Vector2 = focus_target
	# Find rotation needed to move cursor to center of screen
	var direction = -camera.project_ray_normal(target + resolution)
	var target_location = camera.project_position(target + resolution, camera.near)
	var cursor_location = camera.project_position(cursor.position + resolution, camera.near)
	
	var target_yaw = atan2(direction.x, direction.z)
	var target_pitch = asin(-direction.y)
	# Do checks to handle scenario where the cursor angle is "past" 360 degrees + or -
	if target_yaw + PI < camera.rotation.y:
		target_yaw += TAU
	elif camera.rotation.y < target_yaw - PI:
		target_yaw -= TAU
	
	camera.rotation = Util.smerp3d(Vector3(target_pitch, target_yaw, 0.0), camera.rotation, true_delta, 1.0 / (4 * look_sensitivity * LOOK_SPEED))
	camera.rotation.move_toward(Vector3(target_pitch, target_yaw, 0.0), look_sensitivity * LOOK_SPEED * true_delta)
	focus_target =  camera.unproject_position(target_location) - resolution
	cursor.position = camera.unproject_position(cursor_location) - resolution
	
func _focus_ray_cast():
	var resolution = get_viewport().size / 2.0
	var mouse: Vector2 = cursor.position
	var space_state = get_world_3d().direct_space_state
	var origin = camera.project_ray_origin(mouse + resolution)
	var target = origin + camera.project_ray_normal(mouse + resolution) * 100
	var query = PhysicsRayQueryParameters3D.create(origin, target, 0b100)
	query.collide_with_areas = true
	query.collide_with_bodies = true
	var result = space_state.intersect_ray(query)

	if "collider" in result and result["collider"] is DreamDoor:
		result["collider"].interact()

func _process_focus(delta: float):
	var true_delta = delta / Engine.get_time_scale()
	Engine.set_time_scale(move_toward(Engine.get_time_scale(), FOCUS_TIMESCALE, TIMESCALE_DELTA * true_delta))
	velocity.x = 0
	velocity.z = 0
	camera.fov = move_toward(camera.fov, FOV_FOCUS, FOV_DELTA * true_delta)

	if focus_look_time < Time.get_ticks_msec():
		focus_target = cursor.position
	_focus_look_towards(true_delta)

	if Input.is_action_just_pressed("interact"):
		_focus_ray_cast()

func _ground_test_raycast() -> Vector3:
	var origin = global_position
	var target = global_position - Vector3(0.0, 1.5, 0.0)
	var query = PhysicsRayQueryParameters3D.create(origin, target, 0b1000)
	var result = get_world_3d().direct_space_state.intersect_ray(query)
	
	if "position" in result:
		is_on_ground_or_slope = true
		return result["position"] + Vector3(0.0, 1.0, 0.0)
	
	is_on_ground_or_slope = false
	return position

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	if Input.is_action_pressed("focus"):
		_process_focus(delta)
	else:
		_process_move(delta)
	move_and_slide()
	if not is_on_floor():
		if is_on_ground_or_slope:
			global_position = _ground_test_raycast()
	else:
		is_on_ground_or_slope = true
		
func _input_move(event: InputEvent):
	if event is InputEventMouseMotion:
		look_direction.x =  clamp(look_direction.x - event.screen_relative.y * LOOK_SPEED * look_sensitivity, -89, 89)
		look_direction.y = fmod(look_direction.y - event.screen_relative.x * LOOK_SPEED * look_sensitivity, 360);
		if look_direction.y < -180:
			look_direction.y += 360
		elif look_direction.y > 180:
			look_direction.y -= 360
	elif event.is_action("forward"):
		if event.is_pressed():
			if not event.is_echo():
				if Time.get_ticks_msec() < sprint_time:
					is_foward_sprinting = true
				sprint_time = Time.get_ticks_msec() + SPRINT_BUFFER
		else:
			is_foward_sprinting = false
	
func _input_focus(event: InputEvent):
	if event is InputEventMouseMotion:
		cursor.position += event.relative
		focus_look_time = Time.get_ticks_msec() + LOOK_DELAY

func _input(event: InputEvent):
	if Input.is_action_pressed("focus"):
		_input_focus(event)
	else:
		_input_move(event)
		
