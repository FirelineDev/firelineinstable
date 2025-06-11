extends Node3D

@onready var particles: GPUParticles3D = $GPUParticles3D
@onready var particle_material := particles.process_material as ParticleProcessMaterial
@onready var area: Area3D = $GPUParticles3D/DetectorArea

var spread_angle: float = 10.0
var spread_step: float = 2.0
var min_spread: float = 0.0
var max_spread: float = 45.0

func _ready() -> void:
	if area:
		area.body_entered.connect(_on_body_entered)
	else:
		push_error("DetectorArea não encontrado!")

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP and event.pressed:
			spread_angle = clamp(spread_angle + spread_step, min_spread, max_spread)
			update_spread()
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN and event.pressed:
			spread_angle = clamp(spread_angle - spread_step, min_spread, max_spread)
			update_spread()

	if event.is_action_pressed("shoot"):
		start_shooting()
	elif event.is_action_released("shoot"):
		stop_shooting()

func start_shooting() -> void:
	particles.emitting = true
	if area:
		area.monitoring = true
		print("Mangueira ativada!")

func stop_shooting() -> void:
	particles.emitting = false
	if area:
		area.monitoring = false
		print("Mangueira desativada.")

func update_spread() -> void:
	if particle_material:
		particle_material.spread = spread_angle
		print("Spread atualizado para:", spread_angle)

func _on_body_entered(body: Node) -> void:
	print("Objeto detectado:", body)
	if body.is_in_group("inimigo"):
		print("Inimigo atingido!")
		if body.has_method("die"):
			body.die()
		else:
			print("O inimigo não tem o método die().")
	else:
		print("Objeto não é inimigo.")
