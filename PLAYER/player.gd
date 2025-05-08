extends CharacterBody3D

# === CONFIGURÁVEIS ===
const muzzle_spread: float = 3.0
var scroll_in_use = true
var scroll_delay_timer = 0.0
const BASE_SPEED = 4.5
const JUMP_VELOCITY = 4.5
const CROUCH_SPEED_MULTIPLIER = 0.5
const SPRINT_SPEED_MULTIPLIER = 1.8
const SPEED_LERP = 5.0
const MOUSE_SENS = 0.3

const CAMERA_CROUCH_OFFSET = -0.5
const CAMERA_CROUCH_LERP_SPEED = 3.0
const HITBOX_CROUCH_HEIGHT = 1.0
const HITBOX_NORMAL_HEIGHT = 2.0
const HITBOX_CROUCH_INCREASED_HEIGHT = 1.3
const HEIGHT_EPSILON = 0.02
const HITBOX_SLIDE_HEIGHT = 0.8

const CAMERA_PITCH_LIMIT = 89.0

const GUN_BOB_STRENGTH = 3.0
const GUN_BOB_STRENGTH_SPRINT = 6.0
const GUN_BOB_SPEED = 8.0

const CAMERA_SHAKE_LERP_SPEED = 5.0
const CAMERA_SHAKE_SPEED = 20.0
const CAMERA_SHAKE_STRENGTH_SPRINT = 0.15
const CAMERA_SHAKE_STRENGTH_NORMAL = 0.08
const CAMERA_SHAKE_STRENGTH_CROUCH = 0.04

const CAMERA_BREATH_STRENGTH = 0.02
const CAMERA_BREATH_OFFSET = 0.05

const SLIDE_DURATION = 0.6
const SLIDE_FRICTION = 0.5
const SLIDE_FORCE = 9.0
const SLIDE_WINDOW = 1.0

# === VARIÁVEIS ===
var gravity = 200
var dead = false
var is_crouching = false
var is_sprinting = false

var gun_bob_time = 0.0
var camera_shake_time = 0.0
var breath_time = 0.0

var original_gun_position = Vector2.ZERO
var original_camera_position = Vector3.ZERO
var original_camera_local_position = Vector3.ZERO

var is_shake_enabled = true
var was_on_floor = true

var current_speed = BASE_SPEED
var target_speed = BASE_SPEED

var slide_ready_timer = 0.0
var slide_window_active = false
var is_sliding = false
var slide_timer = 0.0

var camera_pitch = 0.0

# === NODES ===
@onready var ray_cast_3d = $Camera3D/Reach
@onready var head_ray_cast = $head_ray_cast
@onready var death_screen = get_node_or_null("CanvasLayer/DeathScreen")
@onready var restart_button = get_node_or_null("CanvasLayer/DeathScreen/Panel/Button")
@onready var camera = $Camera3D
@onready var collision_shape = $CollisionShape3D
@onready var slide_sprite = get_node("CanvasLayer/Animation/slide") as AnimatedSprite2D
@onready var chute_sprite = get_node("CanvasLayer/Animation/chute") as AnimatedSprite2D
@onready var painel_interacao = get_node_or_null("/root/Interaction/Panel")

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

	if death_screen:
		death_screen.visible = false
	if restart_button:
		restart_button.button_up.connect(restart)
	if camera:
		original_camera_position = camera.transform.origin
		original_camera_local_position = camera.position
	if slide_sprite:
		slide_sprite.visible = false
	if head_ray_cast:
		head_ray_cast.target_position = Vector3(0, HITBOX_NORMAL_HEIGHT - HITBOX_CROUCH_HEIGHT + 0.1, 0)
		head_ray_cast.enabled = true
	if painel_interacao:
		painel_interacao.visible = false

func _input(event):
	if dead:
		return

	if event is InputEventMouseMotion:
		rotation_degrees.y -= event.relative.x * MOUSE_SENS
		camera_pitch = clamp(camera_pitch - event.relative.y * MOUSE_SENS, -CAMERA_PITCH_LIMIT, CAMERA_PITCH_LIMIT)
		if camera:
			camera.rotation_degrees.x = camera_pitch

func _process(delta):
	if dead:
		return

	if ray_cast_3d and ray_cast_3d.is_colliding():
		var collider = ray_cast_3d.get_collider()
		if collider is Area3D and collider.name == "gun":
			if painel_interacao:
				painel_interacao.visible = true
		else:
			if painel_interacao:
				painel_interacao.visible = false
	else:
		if painel_interacao:
			painel_interacao.visible = false

	# Continua com o restante do código do _process (ex: shake, breath, etc)
	var is_moving_horizontally = abs(velocity.x) > 0.1 or abs(velocity.z) > 0.1
	if camera and original_camera_position:
		if is_moving_horizontally and is_shake_enabled:
			camera_shake_time += delta * CAMERA_SHAKE_SPEED
			var shake_strength = CAMERA_SHAKE_STRENGTH_CROUCH if is_crouching else (CAMERA_SHAKE_STRENGTH_SPRINT if is_sprinting else CAMERA_SHAKE_STRENGTH_NORMAL)
			var shake_offset = Vector3(sin(camera_shake_time) * shake_strength, cos(camera_shake_time * 2.0) * shake_strength * 0.5, 0)
			var new_cam_pos = original_camera_position + shake_offset
			camera.transform.origin = camera.transform.origin.lerp(new_cam_pos, delta * CAMERA_SHAKE_LERP_SPEED)
		else:
			camera_shake_time += delta * 1.5
			var breath_offset = Vector3(0, sin(camera_shake_time) * CAMERA_BREATH_OFFSET, 0)
			var new_cam_pos = original_camera_position + breath_offset
			camera.transform.origin = camera.transform.origin.lerp(new_cam_pos, delta * 2.0)

	if camera:
		var target_y = original_camera_local_position.y + (CAMERA_CROUCH_OFFSET if is_crouching else 0)
		camera.position.y = lerp(camera.position.y, target_y, delta * CAMERA_CROUCH_LERP_SPEED)



func _physics_process(delta):
	if dead:
		return

	if is_crouching and not Input.is_action_pressed("crouch") and can_stand_up():
		is_crouching = false

	var input_dir = Input.get_vector("move_left", "move_right", "move_forwards", "move_backwards")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	var was_sprinting = is_sprinting

	is_crouching = Input.is_action_pressed("crouch") and is_on_floor() or (is_crouching and not can_stand_up())
	is_sprinting = Input.is_action_pressed("sprint") and not is_crouching

	var is_moving_forward = Input.is_action_pressed("move_forwards") and not Input.is_action_pressed("move_backwards") and input_dir.x == 0

	if not slide_window_active and is_sprinting and is_moving_forward and is_on_floor() and not is_sliding:
		slide_ready_timer = SLIDE_WINDOW
		slide_window_active = true

	if slide_window_active:
		slide_ready_timer = max(0.0, slide_ready_timer - delta)
		if is_crouching:
			if is_on_floor() and is_moving_forward:
				start_slide()
			slide_window_active = false

	if slide_window_active and slide_ready_timer <= 0.0:
		slide_window_active = false

	target_speed = BASE_SPEED
	if is_crouching and not is_sliding:
		target_speed *= CROUCH_SPEED_MULTIPLIER
	elif is_sprinting:
		target_speed *= SPRINT_SPEED_MULTIPLIER

	current_speed = lerp(current_speed, target_speed, delta * SPEED_LERP)

	if collision_shape:
		var shape = collision_shape.shape
		if shape is CapsuleShape3D:
			var target_height = HITBOX_NORMAL_HEIGHT
			if is_crouching and not is_sliding:
				if ray_cast_3d.is_colliding():
					var safe_height = ray_cast_3d.get_collision_point().y - global_transform.origin.y - 0.2
					safe_height = clamp(safe_height, HITBOX_CROUCH_HEIGHT, HITBOX_NORMAL_HEIGHT)
					target_height = safe_height
				else:
					var is_moving = abs(velocity.x) > 0.1 or abs(velocity.z) > 0.1
					target_height = HITBOX_CROUCH_INCREASED_HEIGHT if is_moving else HITBOX_CROUCH_HEIGHT
			if is_sliding:
				target_height = HITBOX_SLIDE_HEIGHT
			if not can_stand_up() and not Input.is_action_pressed("crouch"):
				target_height = HITBOX_CROUCH_HEIGHT
				is_crouching = true
			if abs(shape.height - target_height) > HEIGHT_EPSILON:
				shape.height = lerp(shape.height, target_height, delta * 10.0)

	if is_sliding:
		slide_timer -= delta
		velocity.x = lerp(velocity.x, 0.0, delta * SLIDE_FRICTION)
		velocity.z = lerp(velocity.z, 0.0, delta * SLIDE_FRICTION)
		if slide_timer <= 0.0 or velocity.length() < 0.5:
			is_sliding = false
			if slide_sprite:
				slide_sprite.visible = false
	else:
		if direction != Vector3.ZERO:
			velocity.x = lerp(velocity.x, direction.x * current_speed, delta * SPEED_LERP)
			velocity.z = lerp(velocity.z, direction.z * current_speed, delta * SPEED_LERP)
		else:
			velocity.x = lerp(velocity.x, 0.0, delta * 8.0)
			velocity.z = lerp(velocity.z, 0.0, delta * 8.0)

	if not is_on_floor():
		velocity.y -= gravity * delta

	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		is_shake_enabled = false

	if not was_on_floor and is_on_floor():
		is_shake_enabled = abs(velocity.x) > 0.1 or abs(velocity.z) > 0.1

	was_on_floor = is_on_floor()
	move_and_slide()

func can_stand_up() -> bool:
	if head_ray_cast:
		head_ray_cast.force_raycast_update()
		return not head_ray_cast.is_colliding()
	return true

func start_slide():
	is_sliding = true
	slide_timer = SLIDE_DURATION

	var forward = -transform.basis.z.normalized()
	velocity.x = forward.x * SLIDE_FORCE
	velocity.z = forward.z * SLIDE_FORCE

	if slide_sprite:
		slide_sprite.visible = true
		slide_sprite.play()
		slide_sprite.position = Vector2(slide_sprite.position.x, get_viewport().size.y + 100)
		var target_position = Vector2(slide_sprite.position.x, 110)

		var slide_animation_time = 0.0
		var slide_duration = 1.5

		while slide_animation_time < slide_duration:
			slide_animation_time += get_process_delta_time()
			slide_sprite.position.y = lerp(slide_sprite.position.y, target_position.y, slide_animation_time / slide_duration)
			await get_tree().create_timer(get_process_delta_time()).timeout

		await get_tree().create_timer(0.5).timeout
		slide_sprite.visible = false

func restart():
	get_tree().reload_current_scene()

func kill():
	if dead:
		return
	dead = true
	if death_screen:
		death_screen.visible = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
