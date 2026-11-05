extends CharacterBody2D

@export var max_health: int = 30
var health: int

@export var move_speed: float = 120.0
@export var patrol_distance: float = 200.0
@export var contact_damage: int = 10
@export var damage_cooldown: float = 0.75

var start_position: Vector2
var direction: int = 1
var can_damage: bool = true

@onready var attack_area: Area2D = $AttackArea
@onready var animated_sprite: AnimatedSprite2D = $Node2D/AnimatedSprite2D

func _ready():
	health = max_health
	start_position = global_position
	animated_sprite.play("bat")
	animated_sprite.flip_h = true


func _physics_process(delta):
	# Move horizontally
	velocity.x = direction * move_speed
	velocity.y = 0
	
	move_and_slide()
	
	# Turn around at patrol boundaries
	if global_position.x >= start_position.x + patrol_distance:
		direction = -1
		animated_sprite.flip_h = false
		
	
	elif global_position.x <= start_position.x - patrol_distance:
		direction = 1
		animated_sprite.flip_h = true


func damage_player(player):
	if !can_damage:
		return
	
	can_damage = false
	if animated_sprite.flip_h:
		player.take_damage(contact_damage, 1)
	else:
		player.take_damage(contact_damage, -1)
	
	print("Flying enemy damaged player")
	
	await get_tree().create_timer(damage_cooldown).timeout
	
	can_damage = true


func take_damage(
	amount: int,
	hit_direction: Vector2 = Vector2.ZERO,
	knockback_amount: float = 0.0
):
	health -= amount
	
	print("Flying Enemy Health: ", health)
	
	if health <= 0:
		die()


func die():
	queue_free()

func _on_attack_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") and body.has_method("take_damage"):
		damage_player(body)
