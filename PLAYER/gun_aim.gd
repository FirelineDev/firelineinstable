extends Node3D  # Pode ser seu Player ou o nó da arma/extintor

@onready var aimplayer: RayCast3D = $aimplayer

func _process(_delta):
	if Input.is_action_pressed("shoot"):
		if aimplayer.is_colliding():
			var hit_collider = aimplayer.get_collider()
			print("Acertou: ", hit_collider)

			# Exemplo: se atingiu fogo
			if hit_collider.is_in_group("fire"):
				hit_collider.extinguish()  # Sua função personalizada
