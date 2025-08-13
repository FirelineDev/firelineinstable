extends Node3D

<<<<<<< Updated upstream
@onready var particles := $CPUParticles3D
@onready var area: Area3D = $CPUParticles3D/DetectorArea
@onready var camera = $"../Camera3D"  # ajuste o caminho da câmera aqui
=======
@onready var particles: GPUParticles3D = $GPUParticles3D
@onready var particle_material := particles.process_material as ParticleProcessMaterial
@onready var hit_detector: Area3D = $GPUParticles3D/HitDetector
>>>>>>> Stashed changes

var spread_angle: float = 10.0
var spread_step: float = 2.0
var min_spread: float = 0.0
var max_spread: float = 45.0

<<<<<<< Updated upstream
var push_force = 100.0

func _ready() -> void:
	add_to_group("gun")
	if not is_instance_valid(particles):
		push_error("Nó CPUParticles3D não encontrado!")
		return

	# Garante que há um material válido no CPUParticles3D
	if not particles.get("process_material"):
		particles.set("process_material", ParticleProcessMaterial.new())

	var mat := particles.get("process_material") as ParticleProcessMaterial

	if area:
		area.body_entered.connect(_on_area_body_entered)
		area.monitoring = false  # Começa desativado
   

func _process(delta: float) -> void:
	if not is_instance_valid(particles) or not is_instance_valid(camera):
		return

	var mat := particles.get("process_material") as ParticleProcessMaterial
	if not mat:
		return

	# Pega a direção da câmera (eixo -Z local da câmera é "frente")
	var dir = -camera.global_transform.basis.z.normalized()

	# Atualiza direção das partículas para seguir a câmera
	mat.direction = dir

	# Atualiza rotação do nó CPUParticles3D para alinhar com a câmera
	particles.look_at(particles.global_transform.origin + dir, Vector3.UP)
=======
func _ready() -> void:
	if hit_detector == null:
		print("❌ HitDetector NÃO encontrado! Verifique o nó e o caminho no script.")
	else:
		print("✅ HitDetector encontrado:", hit_detector.name)
		hit_detector.monitoring = true
		hit_detector.monitorable = true
		hit_detector.connect("area_entered", Callable(self, "_on_area_entered"))
>>>>>>> Stashed changes

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP and event.pressed:
			spread_angle = clamp(spread_angle + spread_step, min_spread, max_spread)
			update_spread()
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN and event.pressed:
			spread_angle = clamp(spread_angle - spread_step, min_spread, max_spread)
			update_spread()

	if event.is_action_pressed("shoot"):
		start_shooting()
	elif event.is_action_released("shoot"):
		stop_shooting()
	if event.is_pressed():
		print("Input detectado:", event)
func start_shooting() -> void:
	particles.emitting = true
<<<<<<< Updated upstream
	if area:
		area.monitoring = true
	print("Mangueira ativada!")

func stop_shooting() -> void:
	particles.emitting = false
	if area:
		area.monitoring = false
	print("Mangueira desativada.")
=======
	print("💧 Água disparando!")

func stop_shooting() -> void:
	particles.emitting = false
	print("💧 Água parada!")
	
	


>>>>>>> Stashed changes

func update_spread() -> void:
	var mat := particles.get("process_material") as ParticleProcessMaterial
	if mat:
		mat.spread = spread_angle
		print("Spread atualizado para:", spread_angle)

<<<<<<< Updated upstream
func _on_area_body_entered(body: PhysicsBody3D) -> void:
	if body.is_in_group("movel"):
		# Direção da câmera (jato)
		var dir = -camera.global_transform.basis.z.normalized()
		# Aplica impulso na direção do jato
		body.apply_c_
=======
func _on_area_entered(area: Area3D) -> void:
	print("➡️ Área detectada:", area.name)
	if area.is_in_group("fire"):
		print("🔥 Fogo detectado! Chamando apagar_fogo()")
		area.call("apagar_fogo")
	else:
		print("Área não é fogo.")
>>>>>>> Stashed changes
