extends CharacterBody2D

@export var fire_rate := 2.0 
@onready var explosion_scene = preload("res://asset/outil/Explosion/exlplosion_animation.tscn")
@onready var projectile_scene = preload("res://scène/arme/enemy_projectile.tscn")
@onready var hit_sound = preload("res://asset/Sound/explosion.ogg") 

@onready var detection_area := $DetectionArea
@onready var fire_timer := $FireTimer
@onready var sprite := $AnimatedSprite2D

var can_shoot := true
var player_in_range := false

func _physics_process(_delta):
	if not GameManager.is_game_active:
		return
		
func _ready():
	add_to_group("enemy")
	fire_timer.wait_time = fire_rate
	fire_timer.one_shot = true
	sprite.play("idle")

func _process(_delta):
	if player_in_range and can_shoot:
		shoot()

func _on_detection_area_body_entered(body):
	if body.is_in_group("player"):
		player_in_range = true

func _on_detection_area_body_exited(body):
	if body.is_in_group("player"):
		player_in_range = false

func _on_fire_timer_timeout():
	can_shoot = true

func shoot():
	if not GameManager.is_game_active:
		return
		
	var player = get_tree().current_scene.get_node_or_null("Player")
	if player == null:
		return

	can_shoot = false
	fire_timer.start()

	var directions = [Vector2(-1, 0), Vector2(1, 0)]
	var muzzle_nodes = [$Muzzle, $Muzzle2]

	for i in range(muzzle_nodes.size()):
		var muzzle = muzzle_nodes[i]
		if muzzle:
			var projectile = projectile_scene.instantiate()
			projectile.global_position = muzzle.global_position
			projectile.rotation = muzzle.global_rotation
			projectile.target = player
			
			if projectile.has_method("set_initial_direction"):
				projectile.set_initial_direction(directions[i])
			
			get_parent().add_child(projectile)
			projectile.add_to_group("enemy_projectiles")

func _on_hit_box_body_entered(body):
	# 1. Si c'est un missile du joueur
	if body.is_in_group("player_projectiles"):
		body.queue_free() # ON DÉTRUIT LE MISSILE DU JOUEUR (très important !)
		die()

	# 2. Si c'est le corps du joueur (collision directe)
	elif body.is_in_group("player"):
		# On blesse le joueur
		var life_bar = get_tree().current_scene.find_child("LifeBar", true, false)
		if life_bar and life_bar.has_method("lose_life"):
			life_bar.lose_life()
		
		# On détruit quand même la tourelle (car le joueur lui a foncé dedans)
		die()

func die():
	var explosion = explosion_scene.instantiate()
	get_parent().add_child(explosion)
	explosion.global_position = global_position
	
	if hit_sound:
		var sound_player = AudioStreamPlayer.new()
		sound_player.stream = hit_sound
		get_tree().root.add_child(sound_player)
		sound_player.play()
		sound_player.finished.connect(sound_player.queue_free)
		
	GameManager.add_score(2)
		
	queue_free()
