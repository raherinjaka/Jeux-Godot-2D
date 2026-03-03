extends CharacterBody2D

@export var speed := 60.0
@export var patrol_duration := 3.0

@onready var explosion_scene = preload("res://asset/outil/Explosion/exlplosion_animation.tscn")
@onready var projectile_scene = preload("res://scène/Enemy/missile_ennemy.tscn")
@onready var hit_sound = preload("res://asset/Sound/explosion.ogg") 

@onready var fire_timer = $FireTimer
@onready var muzzle = $Muzzle 
@onready var sprite = $AnimatedSprite2D

var can_shoot := true
var player_target : Node2D = null
var direction := -1 # -1 = Gauche, 1 = Droite
var patrol_timer : Timer 

func _ready():
	add_to_group("enemy")
	fire_timer.wait_time = 1.5
	if not fire_timer.timeout.is_connected(_on_fire_timer_timeout):
		fire_timer.timeout.connect(_on_fire_timer_timeout)
	
	sprite.play()

	patrol_timer = Timer.new()
	add_child(patrol_timer)
	patrol_timer.wait_time = patrol_duration
	patrol_timer.timeout.connect(flip_tank)
	patrol_timer.start()

func _physics_process(_delta):
	if not GameManager.is_game_active:
		return
	
	velocity.y = 0
	
	if player_target:
		if not patrol_timer.is_paused():
			patrol_timer.set_paused(true)
		
		var diff_x = player_target.global_position.x - global_position.x
		
		if diff_x > 5 and direction != 1:
			direction = 1
			update_visuals()
		elif diff_x < -5 and direction != -1:
			direction = -1
			update_visuals()	
		velocity.x = direction * speed

		if can_shoot:
			shoot()
	else:
		if patrol_timer.is_paused():
			patrol_timer.set_paused(false)
		velocity.x = direction * speed
	
	if is_on_wall() and not player_target:
		flip_tank()
		
	move_and_slide()

func flip_tank():
	direction *= -1
	update_visuals()

func update_visuals():
	sprite.flip_h = (direction == -1) 
	
	muzzle.position.x = abs(muzzle.position.x) * direction

func shoot():
	can_shoot = false
	fire_timer.start()
	
	var projectile = projectile_scene.instantiate()
	get_tree().current_scene.add_child(projectile)
	projectile.global_position = muzzle.global_position
	
	if player_target:
		var dir_tir = (player_target.global_position - muzzle.global_position).normalized()
		projectile.rotation = dir_tir.angle()
		if "direction" in projectile:
			projectile.direction = dir_tir

func _on_detection_area_body_entered(body):
	if body.is_in_group("player"):
		player_target = body

func _on_detection_area_body_exited(body):
	if body == player_target:
		player_target = null

func _on_hit_box_body_entered(body):
	if body.is_in_group("player"):
		var life_bar = get_tree().current_scene.find_child("LifeBar", true, false)
		if life_bar and life_bar.has_method("lose_life"):
			life_bar.lose_life()
		die()
	if body.is_in_group("player_projectile"):
		body.queue_free()
		die()

func die():
	set_physics_process(false)
	if has_node("HitBox"):
		$HitBox.queue_free()
	
	# Explosion
	if explosion_scene:
		var explosion = explosion_scene.instantiate()
		get_parent().add_child(explosion)
		explosion.global_position = global_position
		explosion.play("default")

	# Son
	if hit_sound:
		var sound_player = AudioStreamPlayer.new()
		sound_player.stream = hit_sound
		get_tree().root.add_child(sound_player)
		sound_player.play()
		sound_player.finished.connect(sound_player.queue_free)
	
	GameManager.add_score(1)
	queue_free()

func _on_fire_timer_timeout():
	can_shoot = true
