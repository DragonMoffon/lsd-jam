extends CharacterBody3D


@export var camera: Camera3D
@export var cursor: Sprite2D

const FOV_MOVE = 75.0
const FOV_FOCUS = 60.0

const SPEED = 5.0
const JUMP_VELOCITY = 4.5

func _process_move(delta: float):
	cursor.position = cursor.position.move_toward(Vector2(0.0, 0.0), 2*SPEED)
	camera.fov = move_toward(camera.fov, FOV_MOVE, 1)
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
	
func _process_focus(delta: float):
	camera.fov = move_toward(camera.fov, FOV_FOCUS, 1)
	
	var mouse: Vector2 = cursor.position
	var resolution = get_viewport().size / 2.0
	if resolution.x * 0.9 < abs(mouse.x):
		camera.rotation_degrees.y -= 15*sign(mouse.x) * delta
	if resolution.y * 0.9 < abs(mouse.y):
		camera.rotation_degrees.x = clamp(camera.rotation_degrees.x - 15*sign(mouse.y) * delta, -89, 89)
		
	if Input.is_action_just_pressed("interact"):
		var space_state = get_world_3d().direct_space_state
		var end = camera.project_position(mouse + resolution, 100)
		var query = PhysicsRayQueryParameters3D.create(camera.position, end)
		var result = space_state.intersect_ray(query)
		
		var loc: Vector3 = end
		if "position" in result:
			loc = result["position"]

		for i in range(1, 11):
			var t = i/10.0;
			var mi = MeshInstance3D.new()
			mi.position = camera.global_position + t * (loc - camera.position)
			print(t)
			mi.mesh = SphereMesh.new()
			get_parent().add_child(mi)
		
		print(result)

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
		camera.rotation_degrees.y -= event.screen_relative.x;
		camera.rotation_degrees.x = clamp(camera.rotation_degrees.x - event.screen_relative.y, -89, 89)
	
func _input_focus(event):
	if event is InputEventMouseMotion:
		cursor.position += event.relative

func _input(event):
	if Input.is_action_pressed("focus"):
		_input_focus(event)
	else:
		_input_move(event)
		
