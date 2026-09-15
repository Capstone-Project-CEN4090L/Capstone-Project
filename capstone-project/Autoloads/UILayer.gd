extends Node

var UI_scene = preload("res://Assets/Scenes/UI/UI_root.tscn")
var pause_scene = preload("res://Assets/Scenes/UI/pause_menu.tscn")

var UI_root: CanvasLayer
var pause_menu: CanvasLayer


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	UI_root = UI_scene.instantiate()
	pause_menu = pause_scene.instantiate()
	add_child(UI_root)
	add_child(pause_menu)
	pause_menu.visible = false

func set_health_max(max: float) -> void:
	UI_root.get_node("HealthBar").max_value = max

func update_health(new: float) -> void:
	UI_root.get_node("HealthBar").value = new

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("toggle_pause_menu"):
		toggle_pause()
		
func toggle_pause() -> void:
	var new_paused_state = not get_tree().paused
	get_tree().paused = new_paused_state
	pause_menu.visible = new_paused_state
