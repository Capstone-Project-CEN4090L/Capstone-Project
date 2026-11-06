extends Control

const default_level := "res://Assets/Scenes/Areas/first_zone.tscn"

@onready var new_game_button: Button = get_node("Center/PanelContainer/Margin/VBox/NewGameButton")
@onready var resume_game_button: Button = get_node("Center/PanelContainer/Margin/VBox/ResumeGameButton")


func _ready() -> void:
	UILayer.set_gameplay_ui(false)
	new_game_button.pressed.connect(_on_new_game_button_pressed)
	resume_game_button.pressed.connect(_on_resume_game_button_pressed)
	resume_game_button.visible = SaveManager.has_save()

func _on_new_game_button_pressed() -> void:

	UILayer.set_gameplay_ui(true)
	SaveManager.delete_save()
	SaveManager.new_game()
	SceneManager.go_to(default_level)


func _on_resume_game_button_pressed() -> void:
	UILayer.set_gameplay_ui(true)
	if not SaveManager.load_game():
		resume_game_button.visible = false
		return

	var scene_path: String = SaveManager.game_state["last_scene"]
	if scene_path == "":
		scene_path = default_level
	SceneManager.go_to(scene_path)





#func _ready():
	#UILayer.set_gameplay_ui(false)
	#$Center/PanelContainer/Margin/VBox/NewGameButton.pressed.connect(NewGame)
	#$Center/PanelContainer/Margin/VBox/NewGameButton.grab_focus()
#
#func NewGame():
	#UILayer.set_gameplay_ui(true)
	#SceneManager.go_to("res://Assets/Scenes/Areas/first_zone.tscn")
