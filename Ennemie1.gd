extends CharacterBody2D

@export var speed := 400.0
@onready var explosion_scene = preload("res://asset/outil/Explosion/exlplosion_animation.tscn")
@onready var projectile_scene = preload("res://scène/arme/enemy_projectile.tscn")
@onready var hit_sound = preload("res://asset/Sound/explosion.ogg") 

@onready var fire_timer = $FireTimer
@onready var muzzle = $Muzzle 

var can_shoot := true
var player_target : Node2D = null # On stocke le player ici quand il entre dans la zone

func _ready():
	add_to_group("enemy")
	fire_timer.wait_time = 1.5
	# On connecte le timer par code s 'il ne l'est pas dans l'éditeur
	if not fire_timer.timeout.is_connected(_on_fire_timer_timeout):
		fire_timer.timeout.connect(_on_fire_timer_timeout)

func _physics_process(_delta):
	if not GameManager.is_game_active:
		return
	# Mouvement vers la gauche
	velocity.x = -speed
	move_and_slide()

	# Tir automatique si le joueur est dans la DetectionArea
	if player_target and can_shoot:
		shoot()

func shoot():
	can_shoot = false
	fire_timer.start()
	
	var projectile = projectile_scene.instantiate()
	# Ajout à la scène avant de donner la position
	get_tree().current_scene.add_child(projectile)
	projectile.global_position = muzzle.global_position
	
	# Direction du tir vers le joueur
	if player_target:
		var direction = (player_target.global_position - muzzle.global_position).normalized()
		projectile.rotation = direction.angle()
		# Si ton projectile a une variable 'velocity', on lui donne la direction
		if "direction" in projectile:
			projectile.direction = direction

func _on_hit_box_body_entered(body):
	# 1. Collision avec le joueur (corps à corps)
	if body.is_in_group("player"):
		var life_bar = get_tree().current_scene.find_child("LifeBar", true, false)
		if life_bar and life_bar.has_method("lose_life"):
			life_bar.lose_life()
		die()

	# 2. Collision avec un projectile du joueur
	if body.is_in_group("player_projectile"):
		body.queue_free() # Détruit la balle du joueur
		die()

func die():
	set_physics_process(false)
	if has_node("Hitbox"):
		$Hitbox.queue_free()

	var position_explosion = global_position 
	if has_node("ExplosionPos"):
		position_explosion = $ExplosionPos.global_position
		
	if explosion_scene:
		var explosion = explosion_scene.instantiate()
		get_parent().add_child(explosion)
		explosion.global_position = position_explosion
		explosion.play("default")

	if hit_sound:
		var sound_player = AudioStreamPlayer.new()
		sound_player.stream = hit_sound
		get_tree().root.add_child(sound_player)
		sound_player.play()
		sound_player.finished.connect(sound_player.queue_free)
	
	
	GameManager.add_score(1)
	
	queue_free()

func _on_detection_area_body_entered(body):
	if body.is_in_group("player"):
		player_target = body

func _on_detection_area_body_exited(body):
	if body == player_target:
		player_target = null

func _on_fire_timer_timeout():
	can_shoot = true


func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()
