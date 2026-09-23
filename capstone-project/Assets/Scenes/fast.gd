extends CharacterBody2D

@export var max_health: int = 40
var health: int

@export var move_speed: float = 180.0
@export var detection_range: float = 300.0
@export var attack_damage: int = 15
@export var attack_cooldown: float = 0.5
@export var vertical_detection_range: float = 80.0
@export var horizontal_dead_zone: float = 30.0

@export var knockback_strength: float = 170.0
@export var knockback_time: float = 0.2

var being_knocked_back: bool = false

@export var lunge_speed: float = 500.0
@export var lunge_time: float = 0.12

var can_attack: bool = true
var attacking: bool = false

@onready var player = get_tree().get_first_node_in_group("player")
@onready var sprite: AnimatedSprite2D = $Node2D/AnimatedSprite2D
@onready var attack_area: Area2D = $AttackArea
@onready var attack_collision: CollisionShape2D = $AttackArea/CollisionShape2D
@onready var ground_check: RayCast2D = $GroundCheck


func _ready():
	health = max_health


func _physics_process(delta):
	if player == null:
		return
	
	var horizontal_distance = abs(player.global_position.x - global_position.x)
	var vertical_distance = abs(player.global_position.y - global_position.y)
	
	# Knockback temporarily overrides normal movement
	if being_knocked_back:
		move_and_slide()
		return
	
	# Ignore player if they are too far above or below enemy
	if vertical_distance > vertical_detection_range:
		velocity.x = 0
		
		if !attacking:
			sprite.play("idle")
		
		move_and_slide()
		return
	
	# Attack only when player is actually inside AttackArea
	if player_is_in_attack_area():
		velocity.x = 0
		
		if can_attack and !attacking:
			attack()
	
	# Enemy aggressively moves toward player
	elif horizontal_distance <= detection_range and !attacking:
		var x_difference = player.global_position.x - global_position.x
		var direction = 0
		
		# Prevent flipping when player is almost directly above/below
		if abs(x_difference) > horizontal_dead_zone:
			direction = sign(x_difference)
		
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


# Checks whether the player is physically inside the attack box
func player_is_in_attack_area() -> bool:
	if player == null:
		return false
	
	return player in attack_area.get_overlapping_bodies()


func attack():
	attacking = true
	can_attack = false
	velocity.x = 0
	
	var x_difference = player.global_position.x - global_position.x
	var direction = sign(x_difference)
	
	if direction < 0:
		sprite.flip_h = false
		attack_area.position.x = -abs(attack_area.position.x)
	else:
		sprite.flip_h = true
		attack_area.position.x = abs(attack_area.position.x)
	
	sprite.play("attack")
	
	# Player was already confirmed inside the attack area
	if player.has_method("take_damage"):
		print("Fast enemy damaging player")
		player.take_damage(attack_damage)
	
	# Lunge after damage
	velocity.x = direction * lunge_speed
	
	await get_tree().create_timer(lunge_time).timeout
	
	velocity.x = 0
	
	await get_tree().create_timer(attack_cooldown).timeout
	
	attacking = false
	can_attack = true


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
