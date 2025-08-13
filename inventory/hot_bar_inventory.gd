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

func highlight_selected_slot(index: int) -> void:
	for i in range(get_child_count()):
		var slot = get_child(i)
		if slot.has_method("set_highlighted"):
			slot.set_highlighted(i == index)


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
	
func drop_current_hotbar_item(slot_data: SlotData) -> void:
	if not current_inventory_data:
		return

	if not slot_data or not slot_data.item_data:
		print_debug("❌ Nenhum item selecionado para dropar.")
		return
	
	var item_scene = slot_data.item_data.scene
	if not item_scene:
		print_debug("❌ Item não possui uma cena para instanciar.")
		return

	var dropped_item = item_scene.instantiate()

	# Ajuste esse caminho conforme onde está a camera do seu jogador!
	var player = get_node("../../Player")
	var camera = player.get_node("head/Camera3D")
	dropped_item.global_transform.origin = camera.global_transform.origin + camera.global_transform.basis.z * -1.5

	if dropped_item is RigidBody3D:
		var force = camera.global_transform.basis.z * -10.0
		dropped_item.apply_impulse(Vector3.ZERO, force)

	get_tree().current_scene.add_child(dropped_item)

	# ✅ Remover do inventário e atualizar a HUD
	current_inventory_data.remove_item(slot_data)
	populate_hot_bar(current_inventory_data)
	print_debug("✅ Item dropado e removido do inventário.")

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
