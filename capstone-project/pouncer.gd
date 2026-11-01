# uses 4 states for the pounce instead of flags like for the other enemies
# IDLE: waiting for the player to come into range
# WINDUP: crouches and commits to the player's position at that moment
# POUNCE: airborne with the hitbox active
# RECOVER: lands and is vulnerable for a moment

extends CharacterBody2D

enum State { IDLE, WINDUP, POUNCE, RECOVER }
# initializes the state as idle
var state: State = State.IDLE

# export so it can be easily tweaked
@export var max_health: int = 50
var health: int

@export var detection_range: float = 300.0
@export var vertical_detection_range: float = 80.0
@export var windup_time: float = 0.5
@export var recover_time: float = 1.0
@export var pounce_jump_velocity: float = 350.0
@export var max_pounce_speed: float = 400.0
@export var attack_damage: int = 20

@export var knockback_strength: float = 170.0
@export var knockback_time: float = 0.2

var being_knocked_back: bool = false
var state_timer: float = 0.0
var pounce_target: Vector2 = Vector2.ZERO
var has_hit: bool = false

var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")

# @onready delays assignment until node and its children are in the scene tree
@onready var player = get_tree().get_first_node_in_group("player")
@onready var sprite: AnimatedSprite2D = $Node2D/AnimatedSprite2D
@onready var attack_area: Area2D = $AttackArea
@onready var attack_collision: CollisionShape2D = $AttackArea/CollisionShape2D

func _ready():
	health = max_health
	attack_collision.disabled = true
	attack_area.body_entered.connect(_on_attack_area_body_entered)
	
# MOVEMENT LOGIC. runs at a fixed rate. delta is the time since last call
func _physics_process(delta):
	# gravity is now needed for the arc
	if not is_on_floor():
		velocity.y += gravity * delta
	if being_knocked_back:
		move_and_slide()
		return
	match state:
		State.IDLE:
			_idle_state()
		State.WINDUP:
			_windup_state(delta)
		State.POUNCE:
			_pounce_state()
		State.RECOVER:
			_recover_state(delta)
	move_and_slide()
	
func _idle_state():
	velocity.x = 0
	# sprite.play("idle")
	if player == null:
		return
		
	# calculates horizontal and vertical distance between player and enemy
	var horizontal_distance = abs(player.global_position.x - global_position.x)
	var vertical_distance = abs(player.global_position.y - global_position.y)
	
	# if player is within range, begin winding up to attack
	if horizontal_distance <= detection_range and vertical_distance <= vertical_detection_range:
		start_windup()
	
func start_windup():
	state = State.WINDUP
	state_timer = windup_time
	velocity.x = 0
	
	# COMMIT: remember where the player is at the current moment. if the player moves, attack misses
	pounce_target = player.global_position
	
	# face player
	face_direction(sign(pounce_target.x - global_position.x))
	
	# TO DO: change "idle" to "windup" once a crouch/windup animation exists
	# sprite.play("idle")
	
func _windup_state(delta):
	velocity.x = 0
	state_timer -= delta
	if state_timer <= 0.0:
		launch_pounce()
		
func launch_pounce():
	state = State.POUNCE
	has_hit = false
	
	var dx = pounce_target.x - global_position.x
	var air_time = 2.0 * pounce_jump_velocity / gravity
	
	velocity.y = -pounce_jump_velocity
	velocity.x = clamp(dx / air_time, -max_pounce_speed, max_pounce_speed)
	
	attack_collision.set_deferred("disabled", false)
	
	# TO DO: change "idle" to "pounce" once a pouncing animation exists
	# sprite.play("idle")
	
# after landing, move to recover state
func _pounce_state():
	# velocity.y >= 0 avoids triggering on launch frame
	if is_on_floor() and velocity.y >= 0:
		state = State.RECOVER
		state_timer = recover_time
		velocity.x = 0
		attack_collision.set_deferred("disabled", true)
		
# after recovery, move back to initial idle state
func _recover_state(delta):
	velocity.x = 0
	# sprite.play("idle")
	state_timer -= delta
	if state_timer <= 0.0:
		state = State.IDLE
		
# player takes damage if contact is made during pounce
func _on_attack_area_body_entered(body):
	if state != State.POUNCE or has_hit:
		return
	if body.is_in_group("player") and body.has_method("take_damage"):
		if sprite.flip_h:
			body.take_damage(attack_damage, 1)
		else:
			body.take_damage(attack_damage, -1)
		has_hit = true # one hit per pounce
		
func face_direction(direction: float):
	# only flips sprite if facing away from the player
	if direction < 0:
		sprite.flip_h = false
		attack_area.position.x = -abs(attack_area.position.x)
	elif direction > 0:
		sprite.flip_h = true
		attack_area.position.x = abs(attack_area.position.x)
		
# take_damage, apply_knockback and die stay the same as they are for the basic enemies

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
