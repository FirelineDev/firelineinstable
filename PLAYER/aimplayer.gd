extends Node3D

@onready var aimplayer: RayCast3D = $"."              # RayCast
@onready var hand: Node3D = $"../Hand"                # Nó da mão

func _process(_delta):
	if hand == null:
		print_debug("❌ Nó 'Hand' não foi encontrado.")
		return

	# Espera até ter um item dentro da mão
	if hand.get_child_count() == 0:
		# Nenhum item na mão
		return

	var held_item = hand.get_child(0)

	# Verifica se o item pertence ao grupo "gun"
	if not held_item.is_in_group("gun"):
		# Item na mão, mas não é arma
		print_debug("🚫 Item na mão não pertence ao grupo 'gun'.")
		return

	# Item na mão e pertence ao grupo "gun" — pode atirar
	if Input.is_action_pressed("shoot"):
		if aimplayer.is_colliding():
			var hit_collider = aimplayer.get_collider()
			print_debug("🎯 Acertou: ", hit_collider)
		else:
			print_debug("🛑 Nada atingido.")
