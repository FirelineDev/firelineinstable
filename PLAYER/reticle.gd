extends CenterContainer

@export var DOT_RADIUS: float = 1.0
@export var DOT_COLORS: Color = Color.WHITE

func _ready():
	queue_redraw()
	
func _process(delta):
	pass 
	
func _draw():
	# Desenha um círculo no centro do contêiner
	draw_circle(Vector2(size.x / 2, size.y / 2), DOT_RADIUS, DOT_COLORS)
