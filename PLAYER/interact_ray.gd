extends RayCast3D
@onready var tabela_screen = get_node_or_null("CanvasLayer/Interaction")

func _physics_process(delta):
	if tabela_screen:
		if is_colliding():
			tabela_screen.visible = true
			print("Colidindo com: ", get_collider())
		else:
			tabela_screen.visible = false
