extends Area2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$ani_cora.play()


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("jugadores"):
		body.add_vida(1) # le suma 1 de vida
		queue_free()
