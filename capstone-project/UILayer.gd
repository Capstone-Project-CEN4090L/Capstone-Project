extends Node

var UI_scene = preload("res://Assets/Scenes/UI/UI_root.tscn")

var UI_root: CanvasLayer


func _ready() -> void:
	UI_root = UI_scene.instantiate()
	add_child(UI_root)

func set_health_max(max: float) -> void:
	UI_root.get_node("HealthBar").max_value = max

func update_health(new: float) -> void:
	UI_root.get_node("HealthBar").value = new
