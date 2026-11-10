class_name Player
extends CharacterBody3D


@export var camera: Camera3D
@export var cursor: Sprite2D
@export var collider: CapsuleShape3D
@export_range(0.0, 2.0) var look_sensitivity: float = 1.0

const FOV_MOVE = 75.0
const FOV_FOCUS = 60.0

const SPEED = 5.0
const JUMP_VELOCITY = 4.5

const FOCUS_TIMESCALE = 0.05 # TODO: Audio timescale (slowing?)
const BASE_TIMESCALE = 1.0

func spawn(location: Vector3, pitch: float = 0.0, yaw: float = 0.0, scale: float = 1.0):
	position = location
	camera.rotation_degrees.x = pitch
	camera.rotation_degrees.y = yaw
	camera.rotation_degrees.z = 0.0
	
	camera.position.y = 0.8 * scale
	collider.height = 2 * scale
	collider.radius = 0.5 * scale
	# TODO: Scale collider

func _process_move(delta: float):
	cursor.position = cursor.position.move_toward(Vector2(0.0, 0.0), 2*SPEED)
	camera.fov = move_toward(camera.fov, FOV_MOVE, 1)
	Engine.set_time_scale(move_toward(Engine.get_time_scale(), BASE_TIMESCALE, 0.1))
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("left", "right", "forward", "backwards")
	var direction := (camera.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
	
	move_and_slide()
	for i in get_slide_collision_count():
		var other = get_slide_collision(i).get_collider()
		if other is DreamDoor:
			other.interact()
	
func _process_focus(delta: float):
	camera.fov = move_toward(camera.fov, FOV_FOCUS, 1)
	Engine.set_time_scale(move_toward(Engine.get_time_scale(), FOCUS_TIMESCALE, 0.1))
	
	var resolution = get_viewport().size / 2.0
	
	var mouse: Vector2 = cursor.position
	var direction = -camera.project_ray_normal(mouse + resolution)
	var forward = camera.get_global_transform_interpolated().basis.z
	var shifted = forward.move_toward(direction, delta / Engine.get_time_scale())
	var offsets = Vector2(rad_to_deg(asin(-direction.y)), rad_to_deg(atan2(direction.x, direction.z)))
	print(shifted)
	print(rad_to_deg(asin(-direction.y)), " ", camera.rotation_degrees.x)
	print(rad_to_deg(atan2(direction.x, direction.z)), " ", camera.rotation_degrees.y)
	# print(camera.get_global_transform_interpolated().basis.z, direction)

	if Input.is_action_just_pressed("interact"):
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
		
func _input_move(event):
	if event is InputEventMouseMotion:
		camera.rotation_degrees.y = fmod(camera.rotation_degrees.y - event.screen_relative.x * look_sensitivity, 360);
		if camera.rotation_degrees.y < -180:
			camera.rotation_degrees.y += 360
		elif camera.rotation_degrees.y > 180:
			camera.rotation_degrees.y -= 360
		camera.rotation_degrees.x = clamp(camera.rotation_degrees.x - event.screen_relative.y * look_sensitivity, -89, 89)
	
func _input_focus(event):
	if event is InputEventMouseMotion:
		cursor.position += event.relative

func _input(event):
	if Input.is_action_pressed("focus"):
		_input_focus(event)
	else:
		_input_move(event)
		
