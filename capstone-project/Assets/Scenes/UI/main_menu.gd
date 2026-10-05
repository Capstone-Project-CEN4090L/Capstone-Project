extends Control


func _ready():
	UILayer.set_gameplay_ui(false)
	$Center/PanelContainer/Margin/VBox/PlayButton.pressed.connect(play)
	$Center/PanelContainer/Margin/VBox/PlayButton.grab_focus()

func play():
	UILayer.set_gameplay_ui(true)
	SceneManager.go_to("res://Assets/Scenes/Areas/first_zone.tscn")
