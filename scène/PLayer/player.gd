extends CharacterBody2D
class_name player

signal get_damage
signal get_life

@export var speed := 500.0
@export var fire_rate := 0.3

@onready var hit_sound = preload("res://asset/Sound/explosion.ogg")
@onready var explosion_scene = preload("res://asset/outil/Explosion/exlplosion_animation.tscn")
@onready var explosion_scene2 = preload("res://asset/outil/Explosion/explosion_animation_2.tscn")
@onready var bullet_scene = preload("res://scène/arme/bombe.tscn")
@onready var bullet2_scene = preload("res://scène/arme/bombe_2.tscn")
@onready var missile_scene = preload("res://scène/arme/missile_space.tscn")

@onready var fire_position = $FirePosition
@onready var fire_sound = $FireSound
@onready var missile_sound = $MissileSound
@onready var engine_sound = $EngineSound 
@onready var engine_particles = $GPUParticles2D
@onready var Music_sound = $MusicSound
@onready var GameOver_sound = $GameOverSound
@onready var NextMusic_sound = $AudioStreamPlayer2D
@onready var bomb_pos = $bombPos

var next_shot := 0.0

func _ready():
	add_to_group("player")
	
	fire_sound.stream.loop = false
	engine_particles.emitting = false

	if Music_sound and Music_sound.stream:
		var music_stream = Music_sound.stream.duplicate()
		music_stream.loop = true
		Music_sound.stream = music_stream
		Music_sound.play()

func _physics_process(delta):
	if not GameManager.is_game_active:
		return
		
	handle_movement(delta)
	handle_shooting(delta)
	
	if Input.is_key_pressed(KEY_Q):
		var all_progress_bars = get_tree().get_nodes_in_group("ui_bars") 
		for node in get_tree().current_scene.get_children():
			if node.has_method("lose_life"):
				node.lose_life()

	if Input.is_action_pressed("ui_right"):
		if not engine_sound.playing:
			engine_sound.play()
		engine_particles.emitting = true
	else:
		if engine_sound.playing:
			engine_sound.stop()
		engine_particles.emitting = false

	if Input.is_action_just_pressed("ui_missile"):
		fire_missile()
	if Input.is_action_just_pressed("bombe2"):
		fire_bombe2()
	
# Récupérer la taille de l'écran
	var screen_size = get_viewport_rect().size
	
	# BLOQUER LA POSITION (Clamp)
	# 0 = bord gauche/haut, screen_size = bord droit/bas
	position.x = clamp(position.x, 0, screen_size.x)
	position.y = clamp(position.y, 0, screen_size.y)
	#ceci est untest
func handle_movement(_delta):
	var direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	velocity = direction * speed
	move_and_slide()

func handle_shooting(delta):
	if next_shot > 0:
		next_shot -= delta
		
	if Input.is_action_pressed("fire") and next_shot <= 0:
		fire()
		next_shot = fire_rate

func fire():
	var bullet = bullet_scene.instantiate()
	get_tree().current_scene.add_child(bullet)
	bullet.global_position = fire_position.global_position
	bullet.rotation = 0
	fire_sound.stop()
	fire_sound.play()
	
func fire_bombe2():
	if next_shot <= 0:
		var b2 = bullet2_scene.instantiate()
		get_tree().current_scene.add_child(b2)
		
		# On utilise le nouveau point de sortie ici :
		b2.global_position = bomb_pos.global_position
		
		b2.rotation = 0
		fire_sound.stop()
		fire_sound.play()
		next_shot = fire_rate

func fire_missile():
	var missile = missile_scene.instantiate()
	get_tree().current_scene.add_child(missile)
	missile.global_position = fire_position.global_position
	
	if scale.x < 0:
		missile.rotation_degrees = 180 
	else:
		missile.rotation_degrees = 0
	
	missile_sound.stop()
	missile_sound.play()

func die():
	if hit_sound:
		var sound_player = AudioStreamPlayer.new()
		sound_player.stream = hit_sound
		
		get_tree().root.add_child(sound_player)
		sound_player.play()
		sound_player.connect("finished", func(): sound_player.queue_free())
		
	if not visible: 
		return 
	
	var death_pos = global_position
	if has_node("ExplosionPosition"):
		death_pos = $ExplosionPosition.global_position
	
	set_physics_process(false) 
	set_process(false)         
	velocity = Vector2.ZERO
	visible = false           
	
	set_collision_layer_value(1, false)
	set_collision_mask_value(1, false)

	if explosion_scene2:
		var explosion2 = explosion_scene2.instantiate()
		get_parent().add_child(explosion2)
		explosion2.global_position = death_pos
		explosion2.play("default")
		
		if explosion2.has_signal("animation_finished"):
			await explosion2.animation_finished
	
	if Music_sound and Music_sound.playing: 
		Music_sound.stop()
	
	if GameOver_sound: 
		GameOver_sound.play()
	
	var game_over_scene = get_tree().current_scene.find_child("GameOverHud", true, false)
	
	if game_over_scene:
		if game_over_scene.has_method("show_game_over"):
			game_over_scene.show_game_over()
			
	await get_tree().create_timer(2.0).timeout
	queue_free()
	
