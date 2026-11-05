extends CanvasLayer

@export var full_icon: Texture2D
@export var empty_icon: Texture2D

@onready var health_icons: HBoxContainer = $HealthIcons



func update_health(current: int, maximum: int) -> void:
	while health_icons.get_child_count() < maximum:
		health_icons.add_child(health_icons.get_child(0).duplicate())

	for i in health_icons.get_child_count():
		var icon: TextureRect = health_icons.get_child(i)
		icon.visible = i < maximum
		icon.texture = full_icon if i < current else empty_icon
