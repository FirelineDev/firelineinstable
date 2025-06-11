extends Node3D

@export var speed: float = 15.0
var direction = Vector3.ZERO

func _physics_process(delta):
	if direction != Vector3.ZERO:
		translate(direction * speed * delta)

func _on_body_entered(body):
	if body.is_in_group("player"):
		body.kill()  # ou aplique dano
		queue_free()
