extends CharacterBody3D

@export var attack_distance: float = 15.0
@export var retreat_distance: float = 8.0
@export var fireball_scene: PackedScene
@export var move_speed: float = 4.0

@onready var sprite: AnimatedSprite3D = $AnimatedSprite3D
@onready var firepoint: Node3D = $firepoint

var player: Node3D = null
var is_dead = false
var is_attacking = false

func _ready():
	player = get_tree().get_nodes_in_group("player").front()
	add_to_group("inimigo")
	sprite.connect("animation_finished", Callable(self, "_on_animation_finished"))

func _physics_process(delta):
	if is_dead or player == null:
		return

	var distance_to_player = global_position.distance_to(player.global_position)

	if distance_to_player < retreat_distance:
		recuar_do_player(delta)
	elif distance_to_player <= attack_distance:
		atacar_player()
	else:
		aproximar_do_player(delta)

func mover_para(target_pos: Vector3, delta: float):
	var direction = (target_pos - global_position)
	direction.y = 0
	direction = direction.normalized()
	velocity = direction * move_speed
	move_and_slide()

func atacar_player():
	# Só ataca se não estiver no meio da animação
	if not is_attacking:
		is_attacking = true
		velocity = Vector3.ZERO
		move_and_slide()
		look_at(Vector3(player.global_position.x, global_position.y, player.global_position.z), Vector3.UP)
		sprite.play("jogando")

func _on_animation_finished():
	if sprite.animation == "jogando" and not is_dead:
		disparar_fireball()
		is_attacking = false  # Libera para novo ataque

func recuar_do_player(delta):
	sprite.play("recuar")
	var away_direction = (global_position - player.global_position)
	away_direction.y = 0
	away_direction = away_direction.normalized()
	var retreat_position = global_position + away_direction * 5.0
	mover_para(retreat_position, delta)

func aproximar_do_player(delta):
	sprite.play("idle")
	mover_para(player.global_position, delta)

func idle():
	sprite.play("idle")
	velocity = Vector3.ZERO
	move_and_slide()

func disparar_fireball():
	if fireball_scene:
		var fireball = fireball_scene.instantiate()
		fireball.global_transform.origin = firepoint.global_position
		var direction = (player.global_position - firepoint.global_position)
		direction.y = 0
		direction = direction.normalized()
		fireball.look_at(player.global_position, Vector3.UP)
		fireball.set("direction", direction)
		get_tree().current_scene.add_child(fireball)

func die():
	if is_dead:
		return  

	print("Inimigo morreu!")
	is_dead = true
	sprite.play("death")
	set_physics_process(false)
	$CollisionShape3D.disabled = true
	await sprite.animation_finished
	queue_free()
