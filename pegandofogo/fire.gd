extends Area3D

@export var tempo_queima: float = 3.0  # Tempo antes do objeto ser destruído
@export var raio_propagacao: float = 3.0  # Distância para espalhar o fogo

var queimando_objeto = null  # Guarda referência ao objeto queimando

func _ready():
	$Timer.timeout.connect(_on_Timer_timeout)
	body_entered.connect(_on_body_entered)
	$Timer.start()

# Detecta quando um objeto inflamável entra na área de fogo
func _on_body_entered(body):
	if body.is_in_group("inflamavel"):
		queimando_objeto = body  # Guarda a referência do objeto queimando
		print(body.name + " pegou fogo!")  # Debug

# Quando o tempo acabar, queima e propaga o fogo
func _on_Timer_timeout():
	if queimando_objeto and is_instance_valid(queimando_objeto):  
		queimando_objeto.queue_free()  # Remove o objeto incendiado
		print("Objeto destruído!")  # Debug
	
	propagar_fogo()
	queue_free()  # Remove o fogo atual

# Propaga o fogo para objetos próximos
func propagar_fogo():
	var areas = get_tree().get_nodes_in_group("inflamavel")
	for area in areas:
		if global_position.distance_to(area.global_position) < raio_propagacao and area != queimando_objeto:
			var novo_fogo = preload("res://Fogo.tscn").instantiate()
			get_parent().add_child(novo_fogo)
			novo_fogo.global_position = area.global_position
			print("Fogo se espalhou para " + area.name)  # Debug
