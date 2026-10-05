extends CharacterBody2D
var walk_speed = 300.0
var dash_speed = 1600.0
var dashing = false
var dash_wait = false
var lerprate = 0.2
var can_dash = true
var can_jump = true
var can_doublejump = false
var can_airattack = false
var is_airattacking = false
var is_getup = false
const SPEED = 350.0
const JUMP_VELOCITY = -450.0
@export var max_health: int = 100
var health: int
var is_attacking = false
@export var normal_knockback: float = 150.0
@export var upgraded_knockback: float = 300.0


var knockback_upgrade_unlocked: bool = true
var extra_knockback_enabled: bool = false

#@export var shoot_cooldown: float = 0.4
#var can_shoot: bool = true

var bullet = preload("res://Assets/Scenes/bullet.tscn")
var shootsfx = preload("res://Assets/Sounds/shoot.mp3")
var jumpsfx = preload("res://Assets/Sounds/jump.mp3")
var dubjumpsfx = preload("res://Assets/Sounds/doublejump.mp3")
var fallsfx = preload("res://Assets/Sounds/fall.mp3")
var bgmusic = preload("res://Assets/Sounds/stillalive.mp3")
var boostsfx = preload("res://Assets/Sounds/boost.mp3")
var getupsfx = preload("res://Assets/Sounds/getup.mp3")

# Player character is temporarily named "tag"
@onready var tag: AnimatedSprite2D = $AgentAnimator/AnimatedSprite2D
@onready var tag_sword: AnimationPlayer = $AgentAnimator/AnimationPlayer
@onready var muzzle: Marker2D = $AgentAnimator/AnimatedSprite2D/muzzle
@onready var sword: Area2D = $AgentAnimator/AnimatedSprite2D/sword
@onready var airsword: Area2D = $AgentAnimator/AnimatedSprite2D/airsword
@onready var coyote_time: Timer = $CoyoteTime
#@onready var health_bar = get_node("../CanvasLayer/HealthBar")

func _ready() -> void:
	health = max_health
	#health_bar.max_value = max_health
	#health_bar.value = health
	UILayer.set_health_max(max_health)
	UILayer.update_health(health)
	
func _physics_process(delta: float) -> void:
	
	if Input.is_action_just_pressed("toggle_knockback"):
		toggle_knockback_upgrade()
	
	if (is_on_floor() == false) and can_jump and coyote_time.is_stopped():
		coyote_time.start()
	
	var direction = Input.get_axis("ui_left", "ui_right")
	
	# Add the gravity.
	if not is_on_floor() and tag.animation != "boost":
		velocity += get_gravity() * delta * 1.5
	
	# Movement
	if direction and tag.animation != "boost":
		velocity.x = direction * walk_speed
	elif tag.animation != "boost":
		velocity.x = 0
	
	
	# Attack
	if Input.is_action_just_pressed("attack"):
		if can_airattack and !is_airattacking:
			can_airattack = false
			is_airattacking = true
			tag_sword.play("air_attack")
			$sfx.stream = shootsfx
			$sfx.play()
		elif is_on_floor() and !is_airattacking and !is_attacking:
			is_attacking = true
			tag_sword.play("attack")
			$sfx.stream = shootsfx
			$sfx.play()
		#while is_on_floor() and Input.is_action_pressed("run"):
			#if tag.flip_h:
				#velocity.x = SPEED * -1
			#else:
				#velocity.x = SPEED
				
		# Aerial boost, refreshes upon landing
	if Input.is_action_just_pressed("dash") and dashing == false and can_dash and !is_on_floor():
		if is_airattacking:
			is_airattacking = false
			tag_sword.stop()
		velocity.y = 0
		var dir = -1 if tag.flip_h else 1
		tag.play("boost")
		$boost.stream = boostsfx
		$boost.play()
		can_dash = false
		dashing = true
		velocity.x = dash_speed * dir
		dashing = false
		pass

	# Refreshes jump, double jump and dash upon touching the ground
	if is_on_floor():
		can_jump = true
		can_doublejump = true
		can_dash = true
		can_airattack = false
	
	# Called when player falls off map, respawns at a set location
	if (position.y >= 512):
		#velocity = Vector2.ZERO
		#$fall.stream = fallsfx
		#$fall.play()
		#tag.play("fall")
		#position = Vector2(200, -700)
		position = Vector2(-62, -16)

		
	# Player loses control when "fall"ing, so movement functions are disabled.
	# Functions such as gravity continue to work (below).
	if tag.animation == "fall" or tag.animation == "getup":
		if !is_on_floor():
			pass
		else:
			if tag.animation == "fall":
				set_process_input(false)
				$sfx.stream = getupsfx
				$sfx.play()
				tag.play("getup")
				is_getup = true
			pass
	else:
		if direction > 0:
			tag.flip_h = false
			muzzle.position.x = 18.0
			muzzle.rotation_degrees = 0
			sword.scale.x = 1
			airsword.scale.x = 1
		elif direction < 0:
			tag.flip_h = true
			muzzle.position.x = -18.0
			muzzle.rotation_degrees = 180
			sword.scale.x = -1
			airsword.scale.x = -1
		if is_on_floor():
			if is_attacking:
				pass
			elif direction == 0:
				tag.play("idle")
			else:
				tag.play("walk")
		else:
			if tag.animation == "boost" or tag.animation == "doublejump" or is_airattacking:
				pass
			elif can_doublejump == false:
				tag.play("doublejump")
			else:
				tag.play("jump")

		# Double jump function
		# IMPORTANT: Order before jump so it doesn't trigger during the same jump input
		if Input.is_action_just_pressed("up") and !can_jump and can_doublejump:
				$sfx.stream = dubjumpsfx
				$sfx.play()
				can_doublejump = false
				tag.play("doublejump")
				velocity.y = JUMP_VELOCITY * 0.8

		# Handle jump.
		if Input.is_action_just_pressed("up") and can_jump:
			can_airattack = true
			can_jump = false
			$sfx.stream = jumpsfx
			$sfx.play()
			can_doublejump = true
			velocity.y = JUMP_VELOCITY

		if dashing == false:
			if Input.is_action_pressed("ui_left") and !dashing == true:
				velocity.x = lerp(velocity.x, -walk_speed, lerprate)
			if Input.is_action_pressed("ui_right") and !dashing == true:
				velocity.x = lerp(velocity.x, walk_speed, lerprate)
			elif !Input.is_action_pressed("ui_left") and !Input.is_action_pressed("ui_right"):
				velocity.x = lerp(velocity.x, 0.0, 0.1)
	move_and_slide()



# Fires bullets from muzzle node
#func shoot():
	#if !can_shoot:
		#return
	#
	#if tag.animation != "newdj_1":
		#if get_tree().get_node_count_in_group("bullets") > 3:
			#pass
		#else:
			#can_shoot = false
			#
			## Sets muzzle direction before bullet is created
			#if !tag.flip_h:
				#muzzle.rotation_degrees = 0
				#muzzle.position = Vector2(18, 1)
			#else:
				#muzzle.rotation_degrees = 180
				#muzzle.position = Vector2(-18, 1)
			#
			#$sfx.stream = shootsfx
			#$sfx.play()
			#
			#var b = bullet.instantiate()
			#b.transform = muzzle.global_transform
			#
			## Sets bullet direction based on player direction
			#if tag.flip_h:
				#b.direction = Vector2.LEFT
			#else:
				#b.direction = Vector2.RIGHT
			#
			#owner.add_child(b)
			#
			#if tag.animation != "newdj_2":
				#if tag.animation == "jump" or tag.animation == "airshoot":
					#tag.play("airshoot")
				#elif tag.animation == "idle" or tag.animation == "shoot":
					#tag.play("shoot")
				#elif tag.animation == "doublejump" or tag.animation == "djshoot":
					#tag.play("djshoot")
				#elif tag.animation == "boost" or tag.animation == "boostshoot":
					#tag.play("boostshoot")
				#else:
					#tag.play("walkshoot")
			#
			#await get_tree().create_timer(shoot_cooldown).timeout
			#can_shoot = true
	

func _on_animated_sprite_2d_animation_finished() -> void:
	if !is_processing_input():
		set_process_input(true)
	if is_getup:
		tag.play("idle")
		is_getup = false
	if tag.animation == "shoot":
		tag.play("idle")
	if tag.animation == "roll":
		tag.play("walk")
	if tag.animation == "walkshoot":
		tag.play("walk")
	if tag.animation == "boostshoot":
		tag.play("boost")
	if tag.animation == "airshoot":
		tag.play("jump")
	if tag.animation == "djshoot":
		tag.play("doublejump")
	if tag.animation == "boost":
		if can_doublejump:
			tag.play("jump")
		else:
			tag.play("doublejump")
	pass

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "attack":
		is_attacking = false
		tag.play("idle")
	if anim_name == "air_attack":
		is_airattacking = false
		if is_on_floor():
			tag.play("idle")
		elif can_doublejump:
			tag.play("jump")
		else:
			tag.play("doublejump")

func take_damage(amount: int):
	health -= amount
	health = max(health, 0)
	
	#health_bar.value = health
	UILayer.update_health(health)
	
	print("Player Health: ", health)
	
	if health <= 0:
		die()
		

		
func unlock_knockback_upgrade():
	knockback_upgrade_unlocked = true
	extra_knockback_enabled = true
	
func toggle_knockback_upgrade():
	if knockback_upgrade_unlocked:
		extra_knockback_enabled = !extra_knockback_enabled
		
		if extra_knockback_enabled:
			print("Extra knockback ON")
		else:
			print("Extra knockback OFF")

func heal(amount: int):
	health += amount
	health = min(health, max_health)
	#health_bar.value = health
	UILayer.update_health(health)
	print("Player Health: ", health)

func die():
	print("Player died")
	position = Vector2(-62, -16)
	health = 100

func _on_sword_body_entered(body: Node2D) -> void:
	if is_attacking == true:
		if body.has_method("take_damage"):
			var hit_direction = Vector2.RIGHT
			
			if tag.flip_h:
				hit_direction = Vector2.LEFT
			
			var knockback_amount = normal_knockback
			
			if knockback_upgrade_unlocked and extra_knockback_enabled:
				knockback_amount = upgraded_knockback
			
			body.take_damage(10, hit_direction, knockback_amount)

func _on_airsword_body_entered(body: Node2D):
	if is_airattacking == true:
		if body.has_method("take_damage"):
			var hit_direction = Vector2.RIGHT
			
			if tag.flip_h:
				hit_direction = Vector2.LEFT
			
			var knockback_amount = normal_knockback
			
			if knockback_upgrade_unlocked and extra_knockback_enabled:
				knockback_amount = upgraded_knockback
			
			body.take_damage(10, hit_direction, knockback_amount)

@warning_ignore("unused_parameter")
func _unhandled_input(event: InputEvent) ->void:
	if Input.is_action_just_pressed("reset"):
		get_tree().reload_current_scene()


func _on_coyote_time_timeout():
	can_jump = false
	can_airattack = true
