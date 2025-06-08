extends CenterContainer

@export var DOT_RADIUS: float = 2.0
@export var DOT_COLORS: Color = Color.WHITE

func _ready():
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	queue_redraw()

func _process(delta):
	pass 

func _draw():
	var center = size / 2
	draw_circle(center, DOT_RADIUS, DOT_COLORS)
