extends Node


func go_to(path):
	get_tree().paused = false
	get_tree().change_scene_to_file(path)
