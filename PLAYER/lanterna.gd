extends Node3D

@onready var lantern: SpotLight3D = $"."

var lantern_on := false

func _input(event):
	if event.is_action_pressed("toggle_lantern"):
		lantern_on = !lantern_on
		lantern.visible = lantern_on
