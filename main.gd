extends Node3D

@onready var player: CharacterBody3D = $player
@onready var inventory_interface: Control = $UI/InventoryInterface

func set_player_inventory_data(inventory_data: InventoryData) -> void:
	inventory_interface.populate_item_grid(inventory_data.slot_datas)


func _ready() -> void:
	player.toggle_inventory.connect(toggle_inventory_interface)
	inventory_interface.set_player_inventory_data(player.inventory_data)

func toggle_inventory_interface() -> void:
	inventory_interface.visible = not inventory_interface.visible
	
	if inventory_interface.visible:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		
	else:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
