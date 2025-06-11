extends OmniLight3D

@export var min_energy: float = 0.5
@export var max_energy: float = 4.5
@export var flicker_speed: float = 20.0  # quanto maior, mais rápido

var target_energy: float
var current_energy: float

func _ready():
	# Garante que o light_energy já tem valor antes de usar
	current_energy = float(light_energy)
	target_energy = current_energy

func _process(delta):
	# Aproxima a energia atual da nova com suavidade
	current_energy = lerp(current_energy, target_energy, delta * flicker_speed)
	light_energy = current_energy

	# Quando estiver perto o suficiente, define um novo alvo
	if abs(current_energy - target_energy) < 0.05:
		target_energy = randf_range(min_energy, max_energy)
