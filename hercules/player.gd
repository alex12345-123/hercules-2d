extends CharacterBody2D

@export var speed = 500.0
@export var acceleration = 600.0
@export var friction = 1500.0
@export var air_acceleration = 2000.0
@export var air_friction = 700.0
@export var jump_force = -700.0
@export var gravity_scale = 2.0

@export var damage = 255
@export var max_health := 100
var health := 100
var attacking = false

@onready var ani_player = $AnimatedSprite2D
@onready var attack_area = $ataque
@onready var barra_vida = $CanvasLayer/barraVida
@onready var contador: Control = $canva_contador/contador

var atacando = false
var muerto = false

var img_100 = preload("res://barraVida/1barra.png")
var img_75 = preload("res://barraVida/2barra.png")
var img_50 = preload("res://barraVida/3barra.png")
var img_25 = preload("res://barraVida/4barrra.png")
var spawn_point: Vector2
var monedas: int = 0

func _ready():
	health = max_health
	attack_area.monitoring = false
	# Importante: añadimos al grupo para que el Minotauro nos vea
	add_to_group("jugadores") 
	
	if contador: 
		contador.actualizar(0)
	actualizar_interfaz_vida()

func _physics_process(delta: float) -> void:
	if muerto: 
		return 
	var input_axis = Input.get_axis("mover_izquierda", "mover_derecha")

	apply_gravity(delta)

	if not attacking:
		handle_movement(input_axis, delta)
		handle_jump()
		update_animation(input_axis)

	if Input.is_action_just_pressed("puño") and not attacking:
		attack()

	move_and_slide()

func apply_gravity(delta):
	if not is_on_floor():
		velocity += get_gravity() * delta * gravity_scale

func handle_jump():
	if is_on_floor() and Input.is_action_pressed("saltar"):
		velocity.y = jump_force

func handle_movement(input_axis, delta):
	if is_on_floor():
		if input_axis != 0:
			velocity.x = move_toward(velocity.x, speed * input_axis, acceleration * delta)
		else:
			velocity.x = move_toward(velocity.x, 0, friction * delta)
	else:
		# Movimiento en el aire
		if input_axis != 0:
			velocity.x = move_toward(velocity.x, speed * input_axis, air_acceleration * delta)
		else:
			velocity.x = move_toward(velocity.x, 0, air_friction * delta)

func update_animation(input_axis):
	if input_axis != 0:
		ani_player.speed_scale = velocity.length() / 100
		ani_player.flip_h = (input_axis < 0)
		ani_player.play("carrera")
		# Volteamos el área de ataque con el personaje
		attack_area.scale.x = 1 if input_axis > 0 else -1
	elif not is_on_floor():
		ani_player.play("saltar")
	else:
		ani_player.speed_scale = 1
		ani_player.play("reposo")

func attack():
	attacking = true
	velocity.x = 0
	ani_player.speed_scale = 1
	ani_player.play("puño")
	attack_area.monitoring = true

	await ani_player.animation_finished

	attack_area.monitoring = false
	attacking = false

func _on_ataque_body_entered(body: Node2D) -> void:
	if body.is_in_group("enemies") and body.has_method("take_damage"):
		body.take_damage(damage)

func take_damage(amount: int):
	health -= amount
	health = clamp(health, 0, max_health)
	actualizar_interfaz_vida()
	
	if health <= 0:
		die()

func actualizar_interfaz_vida():
	if not barra_vida:
		return
	
	var ratio = float(health) / max_health
	
	if ratio == 1.0:
		barra_vida.texture = img_100
	elif ratio >= 0.75:
		barra_vida.texture = img_75
	elif ratio >= 0.5:
		barra_vida.texture = img_50
	elif ratio > 0:
		barra_vida.texture = img_25
	else:
		barra_vida.texture = null

func die():
	if muerto: return 
	muerto = true
	
	velocity = Vector2.ZERO	
	attack_area.set_deferred("monitoring", false) # Uso seguro de físicas
	
	ani_player.speed_scale = 1.0
	ani_player.play("die")
	
	await ani_player.animation_finished
	
	# --- Lógica de Respawn ---
	respawn()

func respawn():
	health = max_health      # Curar al personaje
	muerto = false           # Ya no está muerto
	global_position = spawn_point # Teletransporte al inicio
	actualizar_interfaz_vida()    # Mostrar vida llena
	ani_player.play("reposo")     # Volver a animación normal
func add_moneda():
	monedas += 1
	if contador: 
		contador.actualizar(monedas)
		
func add_vida(amount: int):
	health += amount
	health = clamp(health, 0, max_health)
	actualizar_interfaz_vida()


func _on_change_scene_body_entered(body: Node2D) -> void:
	pass # Replace with function body.
