extends CharacterBody2D

@export var max_health: int = 100
var health: int

@export var move_speed: float = 200.0
@export var patrol_distance: float = 1600.0
@export var contact_damage: int = 1
@export var damage_cooldown: float = 0.75

var start_position: Vector2 = Vector2(1110.0, 15.0)
var left_point: float = -600.0
var right_point: float = 1110.0
var direction: int = 1
var can_damage: bool = true
var grounded_dash_speed: float = 1400.0
var roll = 1
var dashes_remaining: int = 0

var jumpsfx = preload("res://Assets/Sounds/bossjump.mp3")
var dashsfx = preload("res://Assets/Sounds/bossdash.mp3")

@onready var attack_area: Area2D = $AttackArea
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

func _ready():
	health = max_health
	start_position = global_position
	animated_sprite.play("default")
	animated_sprite.flip_h = true


func _physics_process(delta):
	if roll == 1:
		dash(randi_range(1, 4))
		roll = roll + 1
	elif roll == 2:
		pass

	if not is_on_floor():
		velocity += get_gravity() * delta
		
	if dashes_remaining > 0:
		velocity.x = direction * grounded_dash_speed
		
	move_and_slide()
	
	if dashes_remaining > 0:
		update_dash_state()


func damage_player(player):
	if !can_damage:
		return
	
	can_damage = false
	if animated_sprite.flip_h:
		player.take_damage(contact_damage, 1, true)
	else:
		player.take_damage(contact_damage, -1, true)
	
	print("Boss damaged player")
	
	await get_tree().create_timer(damage_cooldown).timeout
	
	can_damage = true


func take_damage(
	amount: int,
	hit_direction: Vector2 = Vector2.ZERO,
	knockback_amount: float = 0.0
):
	health -= amount
	
	print("Boss Health: ", health)
	
	if health <= 0:
		die()

func dash(dashcount: int):
	dashes_remaining = dashcount
	direction = -1
	animated_sprite.flip_h = false
	
func update_dash_state() -> void:
	var target_x: float = left_point if direction < 0 else right_point
	
	if (global_position.x - target_x) * direction < 0.0:
		return
	
	dashes_remaining -= 1
	
	if dashes_remaining == 0:
		velocity.x = 0.0
		animated_sprite.flip_h = !animated_sprite.flip_h
		print("All Done :D")
		return
	
	direction *= -1
	animated_sprite.flip_h = direction > 0

func die():
	queue_free()

func _on_attack_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") and body.has_method("take_damage"):
		damage_player(body)
