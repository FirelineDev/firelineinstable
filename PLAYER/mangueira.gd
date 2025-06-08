extends Node3D

@onready var particles: GPUParticles3D = $GPUParticles3D
@onready var particle_material := particles.process_material as ParticleProcessMaterial

var spread_angle: float = 10.0
var spread_step: float = 2.0
var min_spread: float = 0.0
var max_spread: float = 45.0

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

func stop_shooting() -> void:
	particles.emitting = false

func update_spread() -> void:
	if particle_material:
		particle_material.spread = spread_angle
		print("Spread atualizado para:", spread_angle)
