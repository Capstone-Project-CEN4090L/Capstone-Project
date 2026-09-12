extends CharacterBody2D

@export var max_health: int = 40
var health: int

@export var move_speed: float = 180.0
@export var detection_range: float = 400.0
@export var attack_range: float = 40.0
@export var attack_damage: int = 15
@export var attack_cooldown: float = 0.5
@export var vertical_detection_range: float = 120.0

@export var lunge_speed: float = 500.0
@export var lunge_time: float = 0.12

var can_attack: bool = true
var attacking: bool = false

@onready var player = get_tree().get_first_node_in_group("player")
@onready var sprite: AnimatedSprite2D = $Node2D/AnimatedSprite2D
@onready var attack_area: Area2D = $AttackArea
@onready var attack_collision: CollisionShape2D = $AttackArea/CollisionShape2D


func _ready():
	health = max_health
	


func _physics_process(delta):
	for body in attack_area.get_overlapping_bodies():
		print("AttackArea currently sees: ", body.name)
	if player == null:
		return
	
	var horizontal_distance = abs(player.global_position.x - global_position.x)
	var vertical_distance = abs(player.global_position.y - global_position.y)
	
	# Player is too far above or below enemy
	if vertical_distance > vertical_detection_range:
		velocity.x = 0
		
		if !attacking:
			sprite.play("idle")
		
		move_and_slide()
		return
	

	# Enemy attacks when player is actually inside attack area
	if player in attack_area.get_overlapping_bodies():
		velocity.x = 0
	
		if can_attack and !attacking:
			attack()
	
	# Enemy aggressively moves toward player
	elif horizontal_distance <= detection_range and !attacking:
		var direction = sign(player.global_position.x - global_position.x)
		
		if direction != 0:
			velocity.x = direction * move_speed
			
			if direction < 0:
				sprite.flip_h = false
				attack_area.position.x = -abs(attack_area.position.x)
			else:
				sprite.flip_h = true
				attack_area.position.x = abs(attack_area.position.x)
			
			sprite.play("walk")
		else:
			velocity.x = 0
			sprite.play("idle")
	
	# Enemy stands still if player is too far away
	elif !attacking:
		velocity.x = 0
		sprite.play("idle")
	
	move_and_slide()


func attack():
	attacking = true
	can_attack = false
	
	var direction = sign(player.global_position.x - global_position.x)
	
	if direction < 0:
		sprite.flip_h = false
		attack_area.position.x = -abs(attack_area.position.x)
	else:
		sprite.flip_h = true
		attack_area.position.x = abs(attack_area.position.x)
	
	sprite.play("attack")
	
	velocity.x = direction * lunge_speed
	
	# Short lunge
	await get_tree().create_timer(0.05).timeout
	
	# Check everything currently inside the attack area
	for body in attack_area.get_overlapping_bodies():
		print("Fast enemy sees: ", body.name)
		
		if body.is_in_group("player") and body.has_method("take_damage"):
			print("Fast enemy damaging player")
			body.take_damage(attack_damage)
	
	await get_tree().create_timer(lunge_time).timeout
	
	velocity.x = 0
	
	await get_tree().create_timer(attack_cooldown).timeout
	
	attacking = false
	can_attack = true


func take_damage(amount: int):
	health -= amount
	
	print("Enemy Health: ", health)
	
	if health <= 0:
		die()


func die():
	queue_free()
