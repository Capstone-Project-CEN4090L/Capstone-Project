extends Area2D

@export var duration: float = 10.0


func _on_body_entered(body):
	if body.is_in_group("player"):
		if body.has_method("activate_low_gravity"):
			body.activate_low_gravity(duration)
			queue_free()
