extends CharacterBody2D
var walk_speed = 400.0
var dash_speed = 1600.0
var dashing = false
var dash_wait = false
var lerprate = 0.1
var can_dash = true
var can_jump = true
var can_doublejump = false
var can_airattack = false
var is_airattacking = false
var is_getup = false
var dead = false
var invincible = false
var being_knocked_back = false
var being_SUPER_knocked_back = false
var knockback_direction = 0
var invincibility_timer = 1.0
var flash_timer = 0.05
const SPEED = 350.0
const JUMP_VELOCITY = -490.0
@export var max_health: int
var health: int
var is_attacking = false
@export var normal_knockback: float = 150.0
@export var upgraded_knockback: float = 300.0
@export var normal_gravity_multiplier: float = 1.5
@export var low_gravity_multiplier: float = 0.3

var gravity_multiplier: float = 1.5
var low_gravity_active: bool = false


var knockback_upgrade_unlocked: bool = true
var extra_knockback_enabled: bool = false

#@export var shoot_cooldown: float = 0.4
#var can_shoot: bool = true

var shootsfx = preload("res://Assets/Sounds/shoot.mp3")
var jumpsfx = preload("res://Assets/Sounds/jump.mp3")
var dubjumpsfx = preload("res://Assets/Sounds/doublejump.mp3")
var fallsfx = preload("res://Assets/Sounds/fall.mp3")
var bgmusic = preload("res://Assets/Sounds/stillalive.mp3")
var boostsfx = preload("res://Assets/Sounds/boost.mp3")
var getupsfx = preload("res://Assets/Sounds/getup.mp3")
var deadsfx = preload("res://Assets/Sounds/fart.mp3")

# Player character is temporarily named "skele"
@onready var skele: AnimatedSprite2D = $AgentAnimator/AnimatedSprite2D
@onready var skele_hitbox: CollisionShape2D = $CollisionShape2D
@onready var skele_sword: AnimationPlayer = $AgentAnimator/AnimationPlayer
@onready var muzzle: Marker2D = $AgentAnimator/AnimatedSprite2D/muzzle
@onready var sword: Area2D = $AgentAnimator/AnimatedSprite2D/sword
@onready var airsword: Area2D = $AgentAnimator/AnimatedSprite2D/airsword
@onready var coyote_time: Timer = $CoyoteTime
@onready var sprite: AnimatedSprite2D = $AgentAnimator/AnimatedSprite2D

signal health_changed(current: int, maximum: int)

func _ready() -> void:
	health = int(SaveManager.get_player_value("health", 5))
	max_health = int(SaveManager.get_player_value("max_health", 5))
	health_changed.connect(UILayer.UI_root.update_health)
	health_changed.emit(health, max_health)
	gravity_multiplier = normal_gravity_multiplier
	
func _physics_process(delta: float) -> void:
	
	if Input.is_action_just_pressed("toggle_knockback"):
		toggle_knockback_upgrade()

	if (is_on_floor() == false) and can_jump and coyote_time.is_stopped():
		coyote_time.start()
	
	var direction = Input.get_axis("ui_left", "ui_right")
	
	# Add the gravity.
	if not is_on_floor() and skele.animation != "boost":
		velocity += get_gravity() * delta * gravity_multiplier
	
	if being_knocked_back:
		velocity.x = 800 * knockback_direction
		if !is_on_floor():
			velocity.y = -400
	
	if being_SUPER_knocked_back:
		velocity.x = 2000 * knockback_direction
		velocity.y = -600
			
	# Movement
	if !being_SUPER_knocked_back and !being_knocked_back and !dead and direction and skele.animation != "boost":
		velocity.x = direction * walk_speed
	elif !being_SUPER_knocked_back and !being_knocked_back and skele.animation != "boost":
		velocity.x = 0
	
	
	# Attack
	if Input.is_action_just_pressed("attack"):
		if not is_on_floor() and can_airattack and !is_airattacking and SaveManager.get_player_value("has_air_attack"):
			is_attacking = false
			can_airattack = false
			is_airattacking = true
			skele_sword.play("air_attack")
			$sfx.stream = shootsfx
			$sfx.play()
		elif is_on_floor() and !is_airattacking and !is_attacking:
			is_attacking = true
			skele_sword.play("attack")
			$sfx.stream = shootsfx
			$sfx.play()
		#while is_on_floor() and Input.is_action_pressed("run"):
			#if skele.flip_h:
				#velocity.x = SPEED * -1
			#else:
				#velocity.x = SPEED
				
		# Aerial boost, refreshes upon landing
	if Input.is_action_just_pressed("dash") and dashing == false and can_dash and !is_on_floor() and SaveManager.get_player_value("has_dash"):
		if is_airattacking:
			is_airattacking = false
			skele_sword.stop()
		velocity.y = 0
		var dir = -1 if skele.flip_h else 1
		skele.play("boost")
		$boost.stream = boostsfx
		$boost.play()
		can_dash = false
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
	if (position.y >= 1000):
		#velocity = Vector2.ZERO
		#$fall.stream = fallsfx
		#$fall.play()
		#skele.play("fall")
		#position = Vector2(200, -700)
		position = Vector2(-62, -78)

		
	# Player loses control when "fall"ing, so movement functions are disabled.
	# Functions such as gravity continue to work (below).
	if skele.animation == "fall" or skele.animation == "getup":
		if !is_on_floor():
			pass
		else:
			if skele.animation == "fall":
				set_process_input(false)
				$sfx.stream = getupsfx
				$sfx.play()
				skele.play("getup")
				is_getup = true
			pass
	else:
		if direction > 0:
			skele.flip_h = false
			muzzle.position.x = 18.0
			muzzle.rotation_degrees = 0
			sword.scale.x = 1
		elif direction < 0:
			skele.flip_h = true
			muzzle.position.x = -18.0
			muzzle.rotation_degrees = 180
			sword.scale.x = -1
		if is_on_floor():
			if is_attacking:
				#move character a little forward
				
				pass
			elif direction == 0 and dead == false:
				skele.play("idle")
			else:
				skele.play("walk")
		else:
			if skele.animation == "boost" or skele.animation == "doublejump" or is_airattacking:
				pass
			elif can_doublejump == false:
				skele.play("doublejump")
			else:
				skele.play("jump")

		# Double jump function
		# IMPORTANT: Order before jump so it doesn't trigger during the same jump input
		if Input.is_action_just_pressed("up") and !can_jump and can_doublejump:
				$sfx.stream = dubjumpsfx
				$sfx.play()
				can_doublejump = false
				skele.play("doublejump")
				velocity.y = JUMP_VELOCITY * 1.02

		# Handle jump.
		if Input.is_action_just_pressed("up") and can_jump:
			if is_attacking:
				is_attacking = false
				skele_sword.stop()

			can_airattack = true
			can_jump = false
			$sfx.stream = jumpsfx
			$sfx.play()
			can_doublejump = true
			velocity.y = JUMP_VELOCITY
			skele.play("jump")
			
		if dashing == false and !is_on_floor():
			if Input.is_action_pressed("ui_left") and !dashing == true:
				velocity.x = lerp(velocity.x, -walk_speed, lerprate)
			if Input.is_action_pressed("ui_right") and !dashing == true:
				velocity.x = lerp(velocity.x, walk_speed, lerprate)
			elif !Input.is_action_pressed("ui_left") and !Input.is_action_pressed("ui_right"):
				velocity.x = lerp(velocity.x, 0.0, 0.1)
				
		# FOR TESTING EXCLUSIVELY! Should not remain in final build!
		if Input.is_action_just_pressed("debug_unlock_dash"):
			if SaveManager.get_player_value("has_dash"):
				SaveManager.set_player_value("has_dash", false)
				print("Dash disabled")
			else:
				SaveManager.set_player_value("has_dash", true)
				print("Dash enabled")
		if Input.is_action_just_pressed("debug_unlock_air_attack"):
			if SaveManager.get_player_value("has_air_attack"):
				SaveManager.set_player_value("has_air_attack", false)
				print("Air Attack disabled")
			else:
				SaveManager.set_player_value("has_air_attack", true)
				print("Air Attack enabled")
	move_and_slide()
	
	if is_on_floor() and is_airattacking:
		cancel_air_attack()


# Fires bullets from muzzle node
#func shoot():
	#if !can_shoot:
		#return
	#
	#if skele.animation != "newdj_1":
		#if get_tree().get_node_count_in_group("bullets") > 3:
			#pass
		#else:
			#can_shoot = false
			#
			## Sets muzzle direction before bullet is created
			#if !skele.flip_h:
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
			#if skele.flip_h:
				#b.direction = Vector2.LEFT
			#else:
				#b.direction = Vector2.RIGHT
			#
			#owner.add_child(b)
			#
			#if skele.animation != "newdj_2":
				#if skele.animation == "jump" or skele.animation == "airshoot":
					#skele.play("airshoot")
				#elif skele.animation == "idle" or skele.animation == "shoot":
					#skele.play("shoot")
				#elif skele.animation == "doublejump" or skele.animation == "djshoot":
					#skele.play("djshoot")
				#elif skele.animation == "boost" or skele.animation == "boostshoot":
					#skele.play("boostshoot")
				#else:
					#skele.play("walkshoot")
			#
			#await get_tree().create_timer(shoot_cooldown).timeout
			#can_shoot = true

func cancel_air_attack() -> void:
	is_airattacking = false
	
	if skele_sword.current_animation == "air_attack":
		skele_sword.stop()
		
	airsword.get_node("attack").set_deferred("disabled", true)

func _on_animated_sprite_2d_animation_finished() -> void:
	if !is_processing_input():
		set_process_input(true)
	if is_getup:
		skele.play("idle")
		is_getup = false
	if skele.animation == "shoot":
		skele.play("idle")
	if skele.animation == "roll":
		skele.play("walk")
	if skele.animation == "walkshoot":
		skele.play("walk")
	if skele.animation == "boostshoot":
		skele.play("boost")
	if skele.animation == "airshoot":
		skele.play("jump")
	if skele.animation == "djshoot":
		skele.play("doublejump")
	if skele.animation == "boost":
		if can_doublejump:
			skele.play("jump")
		else:
			skele.play("doublejump")
	pass

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "attack":
		is_attacking = false
		skele.play("idle")
	if anim_name == "air_attack":
		is_airattacking = false
		if is_on_floor():
			skele.play("idle")
		elif can_doublejump:
			skele.play("jump")
		else:
			skele.play("doublejump")

func set_health(value: int) -> void:
	health = clamp(value, 0, max_health)
	SaveManager.set_player_value("health", health)
	health_changed.emit(health, max_health)

func take_damage(amount: int = 1, hitdirection: int = 0, bosshit: bool = false) -> void:
	if dead or invincible:
		return

	invincible = true
	set_health(health - amount)
	print("Player Health: ", health)

	sprite.modulate = Color(1, 0, 0)
	var tween = create_tween()
	tween.tween_property(sprite, "modulate", Color(1, 1, 1), 0.2)

	if health <= 0:
		die()
		invincible = false
	else:
		knockback_direction = hitdirection
		if bosshit:
			being_SUPER_knocked_back = true
			await get_tree().create_timer(0.3).timeout
		else:
			being_knocked_back = true
			await get_tree().create_timer(0.1).timeout
		if bosshit:
			being_SUPER_knocked_back = false
		else:
			being_knocked_back = false
		await flash()
		invincible = false

		
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

func heal(amount: int) -> void:
	set_health(health + amount)
	print("Player Health: ", health)

func die():
	skele_sword.stop()
	skele_hitbox.position = Vector2(-1, 9.758)
	skele_hitbox.shape.size = Vector2(14.679, 28.463)
	print("Player died")
	dead = true
	$CollisionShape2D.disabled = true
	set_physics_process(false)
	velocity.x = 0
	velocity.y = 0
	skele.play("dead")
	$sfx.stream = deadsfx
	$sfx.play()
	await get_tree().create_timer(2.0).timeout
	position = Vector2(-62, -16)
	set_health(max_health)
	dead = false
	$CollisionShape2D.disabled = false
	set_physics_process(true)
	
func flash() -> void:
	var timer = 0.0
	while timer < invincibility_timer:
		skele.visible = !skele.visible
		await get_tree().create_timer(flash_timer).timeout
		timer += flash_timer
	skele.visible = true

func get_pickup():
	
	pass

func _on_sword_body_entered(body: Node2D) -> void:
	if is_attacking == true:
		if body.has_method("take_damage"):
			var hit_direction = Vector2.RIGHT
			
			if skele.flip_h:
				hit_direction = Vector2.LEFT
			
			var knockback_amount = normal_knockback
			
			if knockback_upgrade_unlocked and extra_knockback_enabled:
				knockback_amount = upgraded_knockback
			
			body.take_damage(10, hit_direction, knockback_amount)

func _on_airsword_body_entered(body: Node2D):
	if is_airattacking == true:
		if body.has_method("take_damage"):
			velocity.y = JUMP_VELOCITY
			can_airattack = true
			can_dash = true
			can_doublejump = true
			var hit_direction = Vector2.RIGHT
			
			if skele.flip_h:
				hit_direction = Vector2.LEFT
			
			var knockback_amount = normal_knockback
			
			if knockback_upgrade_unlocked and extra_knockback_enabled:
				knockback_amount = upgraded_knockback
			
			body.take_damage(10, hit_direction, knockback_amount)
			
func _on_airsword_area_entered(area: Node2D) -> void:
	if is_airattacking and area.has_method("take_damage"):
		velocity.y = JUMP_VELOCITY * 1.5
		area.bounce()
		can_airattack = true
		can_dash = true
		can_doublejump = true

@warning_ignore("unused_parameter")
func _unhandled_input(event: InputEvent) ->void:
	if Input.is_action_just_pressed("reset"):
		SaveManager.set_player_value("has_air_attack", false)
		SaveManager.set_player_value("has_dash", false)
		get_tree().reload_current_scene()


func _on_coyote_time_timeout():
	can_jump = false
	can_airattack = true

func activate_low_gravity(duration: float):
	if low_gravity_active:
		return
	
	low_gravity_active = true
	gravity_multiplier = low_gravity_multiplier
	
	print("Low gravity activated")
	
	await get_tree().create_timer(duration).timeout
	
	gravity_multiplier = normal_gravity_multiplier
	low_gravity_active = false
	
	print("Low gravity ended")
