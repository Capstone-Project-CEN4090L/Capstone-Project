extends Area2D

func _on_body_entered(body: Node2D) -> void:
	if body.has_method("get_pickup"):
		SaveManager.set_player_value("has_air_attack", true)
		queue_free()
