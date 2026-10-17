extends CharacterBody2D

@export var max_health: int = 50
var health: int

@export var move_speed: float = 100.0
@export var detection_range: float = 300.0
@export var attack_range: float = 60.0
@export var attack_damage: int = 20
@export var attack_cooldown: float = 1.0
@export var vertical_detection_range: float = 80.0
#new
@export var knockback_strength: float = 170.0
@export var knockback_time: float = 0.2

var being_knocked_back: bool = false

var can_attack: bool = true
var attacking: bool = false


@onready var player = get_tree().get_first_node_in_group("player")
@onready var sprite: AnimatedSprite2D = $Node2D/AnimatedSprite2D
@onready var attack_area: Area2D = $AttackArea
@onready var attack_collision: CollisionShape2D = $AttackArea/CollisionShape2D
@onready var ground_check: RayCast2D = $GroundCheck

func _ready():
	health = max_health
	attack_collision.disabled = true


func _physics_process(delta):
	if player == null:
		return
	
	var horizontal_distance = abs(player.global_position.x - global_position.x)
	var vertical_distance = abs(player.global_position.y - global_position.y)
	
	if being_knocked_back:
		move_and_slide()
		return
	
	# Player is too far above or below Sans
	if vertical_distance > vertical_detection_range:
		velocity.x = 0
		
		if !attacking:
			sprite.play("idle")
		
		move_and_slide()
		return
	
	# Enemy attacks when player is close horizontally
	if horizontal_distance <= attack_range:
		velocity.x = 0
		
		if can_attack and !attacking:
			attack()
	
	# Enemy walks toward player
	elif horizontal_distance <= detection_range and !attacking:
		var direction = sign(player.global_position.x - global_position.x)
		
		if direction != 0:
			# Move ground check in front of enemy
			ground_check.target_position.x = 25 * direction
			
			# Only follow if there is ground ahead
			if ground_check.is_colliding():
				velocity.x = direction * move_speed
			else:
				velocity.x = 0
				sprite.play("idle")
				move_and_slide()
				return
			
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
	attack_collision.disabled = false
	attacking = true
	can_attack = false
	velocity.x = 0
	
	sprite.play("attack")
	
	# Delay before the attack actually hits
	await get_tree().create_timer(0.2).timeout
	
	for body in attack_area.get_overlapping_bodies():
		print("Attack checking: ", body.name)
		
		if body.is_in_group("player") and body.has_method("take_damage"):
			print("Damaging player")
			body.take_damage(attack_damage)
	
	await get_tree().create_timer(attack_cooldown).timeout
	
	attacking = false
	can_attack = true
	attack_collision.disabled = true

func apply_knockback(hit_direction: Vector2, knockback_amount: float):
	if being_knocked_back:
		return
	
	being_knocked_back = true
	
	velocity.x = hit_direction.x * knockback_amount
	
	await get_tree().create_timer(knockback_time).timeout
	
	velocity.x = 0
	being_knocked_back = false

func take_damage(
	amount: int,
	hit_direction: Vector2 = Vector2.ZERO,
	knockback_amount: float = 150.0
):
	health -= amount
	
	print("Enemy Health: ", health)
	
	if hit_direction != Vector2.ZERO:
		apply_knockback(hit_direction, knockback_amount)
	
	if health <= 0:
		die()

func die():
	queue_free()
