class_name Player
extends CharacterBody3D


@export var camera: Camera3D
@export var cursor: Sprite2D
@export var collider: CapsuleShape3D
@export_range(0.0, 2.0) var look_sensitivity: float = 1.0

const FOV_MOVE := 75.0
const FOV_FOCUS := 60.0

const SPEED := 5.0
const SPRINT_SPEED := 15.0
var sprint_time := 0.0
var is_foward_sprinting := false
const SPRINT_BUFFER := 320 # ms
var focus_look_time := 0.0
const LOOK_DELAY := 500 # ms
const LOOK_SPEED := 0.5

const FOCUS_TIMESCALE := 0.05 # TODO: Audio timescale (slowing?)
const BASE_TIMESCALE := 1.0

func spawn(location: Vector3, pitch: float = 0.0, yaw: float = 0.0, scale: float = 1.0):
	cursor.position = Vector2(0.0, 0.0)
	sprint_time = Time.get_ticks_msec()
	focus_look_time = sprint_time
	
	position = location
	camera.rotation_degrees.x = pitch
	camera.rotation_degrees.y = yaw
	camera.rotation_degrees.z = 0.0
	
	camera.position.y = 0.8 * scale
	collider.height = 2 * scale
	collider.radius = 0.5 * scale
	# TODO: Scale collider

func _process_move(delta: float):
	cursor.position = Util.smerp2d(cursor.position, Vector2(0.0, 0.0), delta,  1.0)
	camera.fov = move_toward(camera.fov, FOV_MOVE, 1)
	Engine.set_time_scale(move_toward(Engine.get_time_scale(), BASE_TIMESCALE, 0.1))
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("left", "right", "forward", "backwards")
	var is_sprinting := (Input.is_action_pressed("sprint") or is_foward_sprinting) and Input.is_action_pressed("forward")
	print(is_sprinting)
	var speed := SPRINT_SPEED if is_sprinting else SPEED
	var direction := (camera.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)
	
	move_and_slide()
	for i in get_slide_collision_count():
		var other = get_slide_collision(i).get_collider()
		if other is DreamDoor:
			other.interact()
	
func _process_focus(delta: float):
	Engine.set_time_scale(move_toward(Engine.get_time_scale(), FOCUS_TIMESCALE, 0.1))
	velocity.x = 0
	velocity.z = 0
	var true_delta = delta / Engine.get_time_scale()
	camera.fov = move_toward(camera.fov, FOV_FOCUS, 60.0*true_delta)
	
	var resolution = get_viewport().size / 2.0
	
	if focus_look_time < Time.get_ticks_msec():
		var mouse: Vector2 = cursor.position
		# Find rotation needed to move cursor to center of screen
		var direction = -camera.project_ray_normal(mouse + resolution)
		var mouse_location = camera.project_position(mouse + resolution, camera.near)
		
		var target_yaw = atan2(direction.x, direction.z)
		var target_pitch = asin(-direction.y)
		# Do checks to handle scenario where the cursor angle is "past" 360 degrees + or -
		if target_yaw + PI < camera.rotation.y:
			target_yaw += TAU
		elif camera.rotation.y < target_yaw - PI:
			target_yaw -= TAU
		
		camera.rotation = Util.smerp3d(Vector3(target_pitch, target_yaw, 0.0), camera.rotation, true_delta, 1.0 / (4 * look_sensitivity * LOOK_SPEED))
		camera.rotation.move_toward(Vector3(target_pitch, target_yaw, 0.0), look_sensitivity * LOOK_SPEED * true_delta)
		cursor.position  = camera.unproject_position(mouse_location) - resolution

	if Input.is_action_just_pressed("interact"):
		var mouse: Vector2 = cursor.position
		var space_state = get_world_3d().direct_space_state
		var origin = camera.project_ray_origin(mouse + resolution)
		var target = origin + camera.project_ray_normal(mouse + resolution) * 100
		var query = PhysicsRayQueryParameters3D.create(origin, target, 0b100)
		var result = space_state.intersect_ray(query)

		if "collider" in result and result["collider"] is DreamDoor:
			result["collider"].interact()

	move_and_slide()

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	if Input.is_action_pressed("focus"):
		_process_focus(delta)
	else:
		_process_move(delta)
		
func _input_move(event: InputEvent):
	if event is InputEventMouseMotion:
		camera.rotation_degrees.y = fmod(camera.rotation_degrees.y - event.screen_relative.x * LOOK_SPEED * look_sensitivity, 360);
		if camera.rotation_degrees.y < -180:
			camera.rotation_degrees.y += 360
		elif camera.rotation_degrees.y > 180:
			camera.rotation_degrees.y -= 360
		camera.rotation_degrees.x = clamp(camera.rotation_degrees.x - event.screen_relative.y * LOOK_SPEED * look_sensitivity, -89, 89)
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
		
