extends CharacterBody2D

@onready var gravity: int = ProjectSettings.get("physics/2d/default_gravity")

@export var speed = 100
@export var attack_range = 150
@export var damage = 10
@export var attack_cooldown = 1.0

var sentido = 1
var player = null
var can_attack = true
var attacking = false

func _ready():
	player = get_tree().get_first_node_in_group("jugadores")
	$Area2D.monitoring = false
	add_to_group("enemies")

func _physics_process(delta: float) -> void:
	velocity.y += gravity * delta

	if not attacking:
		patrol() # El minotauro siempre patrulla hasta que choque con algo

	move_and_slide()

func patrol():
	if is_on_wall():
		sentido = -sentido

	if sentido == 1 and $derecha.is_colliding():
		velocity.x = speed
		$ani_minotauro.flip_h = false
		$ani_minotauro.play("walk")
	elif sentido == -1 and $izquierda.is_colliding():
		velocity.x = -speed
		$ani_minotauro.flip_h = true
		$ani_minotauro.play("walk")
	else:
		sentido = -sentido

func start_attack(objetivo):
	attacking = true
	can_attack = false
	velocity.x = 0
	$ani_minotauro.play("attack")
	$Area2D.monitoring = true

	if objetivo.has_method("recibir_dano"):
		objetivo.recibir_dano(damage)

func _on_ani_minotauro_animation_finished():
	if $ani_minotauro.animation == "attack":
		attacking = false
		# Esperar un segundo antes de poder volver a atacar
		await get_tree().create_timer(attack_cooldown).timeout
		can_attack = true

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("jugadores"):
		if can_attack and not attacking:
			iniciar_ataque_por_choque(body)

func iniciar_ataque_por_choque(objetivo):
	attacking = true
	can_attack = false
	velocity.x = 0 # Se detiene para golpear
	$ani_minotauro.play("attack")
