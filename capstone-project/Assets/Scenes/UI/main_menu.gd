extends Control


func _ready():
	$Center/PanelContainer/Margin/VBox/PlayButton.pressed.connect(play)
	$Center/PanelContainer/Margin/VBox/PlayButton.grab_focus()

func play():
	SceneManager.go_to("res://Assets/Scenes/Areas/first_zone.tscn")
