extends Area2D

func _on_body_entered(body: Node2D) -> void:
	if body.has_method("get_pickup"):
		Globals.air_attack_unlocked = true
		queue_free()
