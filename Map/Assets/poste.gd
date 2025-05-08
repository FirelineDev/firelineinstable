# Poste.gd — anexe ao Node3D raiz da cena "poste"
extends Node3D

@onready var cilindro: MeshInstance3D = $Cilindro
@onready var luz: OmniLight3D       = $OmniLight3D

# Tempo entre cada sequência de 2 piscadas
const CICLO_INTERVALO := 5.0  
# Duração de cada apagão
const DURACAO_OFF     := 0.1  
# Intervalo entre o primeiro e o segundo piscar
const DURACAO_ON      := 0.1  

func _ready():
	piscar_duplo()

func piscar_duplo() -> void:
	# espera antes de iniciar o ciclo
	await get_tree().create_timer(CICLO_INTERVALO).timeout

	# faz duas piscadas
	for i in range(2):
		# apaga cilindro e luz
		cilindro.visible = false
		luz.visible     = false
		await get_tree().create_timer(DURACAO_OFF).timeout

		# acende de novo
		cilindro.visible = true
		luz.visible     = true
		if i == 0:
			await get_tree().create_timer(DURACAO_ON).timeout

	# repete indefinidamente
	piscar_duplo()
