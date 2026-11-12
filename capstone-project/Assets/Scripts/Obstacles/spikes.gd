extends Area2D

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	
func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		body.skele.modulate = Color(1, 0, 0)
		var tween = create_tween()
		tween.tween_property(body.skele, "modulate", Color(1, 1, 1), 0.2)
		body.die()
