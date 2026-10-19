extends Area2D

func _on_body_entered(body: Node2D) -> void:
	if body.has_method("get_pickup"):
		Globals.dash_unlocked = true
		queue_free()
