extends Node3D

@onready var particles = $GPUParticles3D
@onready var light = $OmniLight3D
@onready var collision_area: Area3D = $Area3D
@onready var hit_detector: Area3D = $hit_detector

func _ready():
	add_to_group("fire")

func apagar_fogo():
	if particles.emitting == false:
		return
	particles.emitting = false
	light.light_energy = 0.0
