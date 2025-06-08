extends Node

const PickUp = preload("res://PLAYER/mangueira.tscn")
@onready var player: CharacterBody3D = $Player
@onready var inventory_interface: Control = $UI/InventoryInterface
@onready var hot_bar_inventory: PanelContainer = $UI/HotBarInventory

var saved_yaw = 0.0
var saved_pitch = 0.0
var camera_locked = false

func _ready() -> void:
	player.toggle_inventory.connect(toggle_inventory_interface)
	inventory_interface.set_player_inventory_data(player.inventory_data)
	hot_bar_inventory.set_inventory_data(player.inventory_data)
	
	for node in get_tree().get_nodes_in_group("external_inventory"):
		node.toggle_inventory.connect(toggle_inventory_interface)

func toggle_inventory_interface(external_inventory_owner = null) -> void:
	inventory_interface.visible = not inventory_interface.visible
	
	if inventory_interface.visible:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		hot_bar_inventory.hide()
		camera_locked = true
		player.camera_enabled = false
	else:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		hot_bar_inventory.show()
		camera_locked = false
		player.camera_enabled = true
	
	if external_inventory_owner and inventory_interface.visible:
		inventory_interface.set_external_inventory(external_inventory_owner)
	else:
		inventory_interface.clear_external_inventory()
