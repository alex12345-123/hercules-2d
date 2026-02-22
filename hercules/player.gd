extends CharacterBody2D
@export var jump_force = -700
@export var air_acceleration = 2000
@export var air_friction = 700
@export var friction = 1500
@export var gravity_scale = 2


@export var speed = 500
@export var acceleration = 600

func apply_gravity(delta):
	if not is_on_floor():
		velocity+=get_gravity() * delta * gravity_scale


func handle_jump():
	if is_on_floor():
		if Input.is_action_pressed("saltar"):
			velocity.y = jump_force
			
func handle_acceleration(input_axis, delta):
	if not is_on_floor(): return
	if input_axis != 0:
		velocity.x = move_toward(velocity.x, speed*input_axis, acceleration*delta)

	
func handle_air_acceleration(input_axis, delta):
	if is_on_floor(): return
	if input_axis != 0:
		velocity.x = move_toward(velocity.x, speed*input_axis, air_acceleration *delta)
		

func apply_friction(input_axis, delta):
	if input_axis==0 and is_on_floor():
		velocity.x = move_toward(velocity.x, 0, friction*delta)


@onready var ani_player = $AnimatedSprite2D

func update_animation(input_axis):
	if input_axis !=0:
		# velocidad de la animación será dependiente de la velocidad
		ani_player.speed_scale = velocity.length()/100
		ani_player.flip_h = (input_axis<0)
		ani_player.play("carrera")
	elif not is_on_floor():
		ani_player.play("saltar")
	else:
		ani_player.speed_scale=1
		ani_player.play("idle")


var attacking = false
@export var damage = 1

@onready var attack_area = $ataque

func _ready():
	attack_area.monitoring = false

func attack():
	attacking = true
	velocity.x = 0
	ani_player.speed_scale = 1
	ani_player.play("puño") 
	attack_area.monitoring = true

	await ani_player.animation_finished

	attack_area.monitoring = false
	attacking = false

func _physics_process(delta: float) -> void:
	var input_axis = Input.get_axis("mover_izquierda","mover_derecha")

	apply_gravity(delta)

	if not attacking:
		handle_acceleration(input_axis, delta)
		handle_air_acceleration(input_axis, delta)
		apply_friction(input_axis, delta)
		handle_jump()
		update_animation(input_axis)

	if Input.is_action_just_pressed("ataque") and not attacking:
		attack()

	move_and_slide()


func _on_ataque_body_entered(body: Node2D) -> void:
	if body.is_in_group("enemies"):
		body.take_damage(damage)
