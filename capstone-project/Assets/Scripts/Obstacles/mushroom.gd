extends Area2D

func _ready() -> void:
	$AnimatedSprite2D.play("default")
	pass

func take_damage():
	pass

func bounce():
		$AnimatedSprite2D.play("bounce")
