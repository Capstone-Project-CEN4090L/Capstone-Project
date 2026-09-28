extends CanvasLayer

@onready var main_page = $Root/Center/PanelContainer/Margin/MainPage
@onready var options_page = $Root/Center/PanelContainer/Margin/OptionsPage

func _ready():
	visible = false
	main_page.get_node("ResumeButton").pressed.connect(close_menu)
	main_page.get_node("OptionsButton").pressed.connect(show_page.bind(options_page))
	main_page.get_node("QuitButton").pressed.connect(get_tree().quit)
	options_page.get_node("BackButton").pressed.connect(show_page.bind(main_page))
	options_page.get_node("VolumeSlider").value_changed.connect(set_volume)

func show_page(page):
	main_page.visible = page == main_page
	options_page.visible = page == options_page
	page.get_child(1).grab_focus()

func open_menu():
	visible = true
	get_tree().paused = true
	show_page(main_page)

func close_menu():
	visible = false
	get_tree().paused = false

func _unhandled_input(event):
	if event.is_action_pressed("toggle_pause_menu"):
		if not visible:
			open_menu()
		elif options_page.visible:
			show_page(main_page)
		else:
			close_menu()
		get_viewport().set_input_as_handled()

func set_volume(value):
	var bus = AudioServer.get_bus_index("Master")
	AudioServer.set_bus_volume_db(bus, linear_to_db(value))
