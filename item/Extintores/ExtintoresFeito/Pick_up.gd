extends RigidBody3D

@export var slot_data: SlotData

func get_slot_data() -> SlotData:
	return slot_data

func on_player_interact(player: Node):
	print(">>> O item foi interagido!")
	if player.has_method("add_to_inventory"):
		print(">>> Player tem método add_to_inventory!")
		var success = player.add_to_inventory(slot_data)
		print(">>> Adicionado ao inventário?", success)
		if success:
			print(">>> Removendo da cena.")
			queue_free()
	else:
		print(">>> Player NÃO tem método add_to_inventory")
