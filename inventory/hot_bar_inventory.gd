extends PanelContainer

const Slot = preload("res://inventory/slot.tscn")

@onready var h_box_container: HBoxContainer = $MarginContainer/HBoxContainer
@onready var player: CharacterBody3D = $"../../Player"

var current_inventory_data: InventoryData
var selected_slot_index: int = -1  

func _ready() -> void:
	if player == null:
		push_warning("Player não encontrado via caminho ../../Player")
	elif not player.has_method("update_hand_item"):
		push_warning("Player não possui método 'update_hand_item'!")

func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("item1"):
		use_hotbar_item(0)
	elif Input.is_action_just_pressed("item2"):
		use_hotbar_item(1)
	elif Input.is_action_just_pressed("item3"):
		use_hotbar_item(2)

func set_inventory_data(inventory_data: InventoryData) -> void:
	current_inventory_data = inventory_data
	inventory_data.inventory_updated.connect(populate_hot_bar)
	populate_hot_bar(inventory_data)

func populate_hot_bar(inventory_data: InventoryData) -> void:
	# Remove os slots antigos
	for child in h_box_container.get_children():
		child.queue_free()

	# Cria novos slots
	for slot_data in inventory_data.slot_datas.slice(0, 3):
		var slot = Slot.instantiate()
		h_box_container.add_child(slot)
		slot.slot_clicked.connect(inventory_data.on_slot_clicked)
		
		if slot_data:
			slot.set_slot_data(slot_data)
	
	# Define opacidade padrão
	for i in range(h_box_container.get_child_count()):
		var slot = h_box_container.get_child(i)
		if slot:
			slot.modulate = Color(1, 1, 1, 0.5)

	selected_slot_index = -1  

func highlight_selected_slot(new_index: int) -> void:
	if selected_slot_index != -1:
		var old_slot = h_box_container.get_child(selected_slot_index)
		if old_slot:
			old_slot.modulate = Color(1, 1, 1, 0.5)

	if new_index >= 0 and new_index < h_box_container.get_child_count():
		var new_slot = h_box_container.get_child(new_index)
		if new_slot:
			new_slot.modulate = Color(1, 1, 1, 1.0)
	
	selected_slot_index = new_index

func use_hotbar_item(index: int) -> void:
	if not current_inventory_data:
		return
	
	if index < current_inventory_data.slot_datas.size():
		var slot_data = current_inventory_data.slot_datas[index]
		if slot_data and slot_data.item_data:
			current_inventory_data.use_item(slot_data, slot_data.item_data)

			if player and player.has_method("update_hand_item"):
				player.update_hand_item(slot_data)
			else:
				push_warning("Player não está atribuído ou não tem update_hand_item!")

		highlight_selected_slot(index)
