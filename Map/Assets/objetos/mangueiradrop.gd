extends Area3D

var jogador_na_area = false
var player_ref = null

func _ready():
	connect("body_entered", Callable(self, "_on_body_entered"))
	connect("body_exited", Callable(self, "_on_body_exited"))

func _on_body_entered(body):
	if body.name == "Player":
		jogador_na_area = true
		player_ref = body

func _on_body_exited(body):
	if body.name == "Player":
		jogador_na_area = false
		player_ref = null

func _process(_delta):
	if jogador_na_area and Input.is_action_just_pressed("interagir"):
		if player_ref:
			player_ref.pegar_arma()
			get_parent().queue_free()
