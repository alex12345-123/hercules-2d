extends Area2D


func _ready() -> void:
	$ani_cora.play()


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("jugadores"):
		body.add_vida(25)
		queue_free()
