extends CharacterBody2D

@export var speed = 500
@export var acceleration = 600
@export var friction = 1500

@export var air_acceleration = 2000
@export var air_friction = 700

@export var jump_force = -700
@export var gravity_scale = 2

@export var damage = 1
@export var max_health := 100

var attacking = false
var health := max_health

@onready var ani_player = $AnimatedSprite2D
@onready var attack_area = $ataque
@onready var health_bar = $CanvasLayer/ProgressBar


func _ready():
	attack_area.monitoring = false
	update_health_bar()


func _physics_process(delta: float) -> void:
	var input_axis = Input.get_axis("mover_izquierda","mover_derecha")

	apply_gravity(delta)

	if not attacking:
		handle_acceleration(input_axis, delta)
		handle_air_acceleration(input_axis, delta)
		apply_friction(input_axis, delta)
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


func handle_acceleration(input_axis, delta):
	if not is_on_floor():
		return
	if input_axis != 0:
		velocity.x = move_toward(velocity.x, speed * input_axis, acceleration * delta)


func handle_air_acceleration(input_axis, delta):
	if is_on_floor():
		return
	if input_axis != 0:
		velocity.x = move_toward(velocity.x, speed * input_axis, air_acceleration * delta)


func apply_friction(input_axis, delta):
	if input_axis == 0 and is_on_floor():
		velocity.x = move_toward(velocity.x, 0, friction * delta)


func update_animation(input_axis):
	if input_axis != 0:
		ani_player.speed_scale = velocity.length() / 100
		ani_player.flip_h = (input_axis < 0)
		ani_player.play("carrera")
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
	if body.is_in_group("enemies"):
		body.take_damage(damage)


func take_damage(amount: int):
	health -= amount
	health = clamp(health, 0, max_health)
	update_health_bar()

	if health <= 0:
		die()


func die():
	queue_free()


func update_health_bar():
	if health_bar:
		health_bar.value = health
		
@onready var barra_vida = $CanvasLayer/barraVida

# 2. Precargar las imágenes (ASEGÚRATE DE PONER LA RUTA CORRECTA DE TUS ASSETS)
var img_100 = preload("res://barraVida/1barra.png")
var img_75 = preload("res://barraVida/2barra.png")
var img_50 = preload("res://barraVida/3barra.png")
var img_25 = preload("res://barraVida/4barrra.png")

var salud_maxima: int = 100
var salud_actual: int = 100


func recibir_dano(cantidad):
	salud_actual -= cantidad
	
	if salud_actual <= 0:
		salud_actual = 0
		actualizar_interfaz_vida()
		get_tree().reload_current_scene() 
	else:
		actualizar_interfaz_vida()

func actualizar_interfaz_vida():
	var porcentaje = (float(salud_actual) / salud_maxima) * 100.0
	
	if porcentaje >= 100:
		barra_vida.texture = img_100
	elif porcentaje >= 75:
		barra_vida.texture = img_75
	elif porcentaje >= 50:
		barra_vida.texture = img_50
	elif porcentaje > 0:
		barra_vida.texture = img_25
	else:
		barra_vida.texture = null
