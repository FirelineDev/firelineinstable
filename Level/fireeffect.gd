extends OmniLight3D

@export var min_energy: float = 0.5
@export var max_energy: float = 4.5
@export var flicker_speed: float = 20.0  

var target_energy: float
var current_energy: float

func _ready():

	current_energy = float(light_energy)
	target_energy = current_energy

func _process(delta):
	current_energy = lerp(current_energy, target_energy, delta * flicker_speed)
	light_energy = current_energy
	if abs(current_energy - target_energy) < 0.05:
		target_energy = randf_range(min_energy, max_energy)
