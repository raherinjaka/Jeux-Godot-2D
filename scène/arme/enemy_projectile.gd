extends Area2D

@export var speed := 500.0
@export var turn_speed := 3.0  
@export var lifetime := 4.0   

@onready var explosion_scene = preload("res://asset/outil/Explosion/exlplosion_animation.tscn")
@onready var hit_sound = preload("res://asset/Sound/explosion.ogg") 

var target: Node2D = null
var velocity := Vector2.ZERO 

func _ready():
	add_to_group("enemy_projectiles")
	target = get_tree().get_first_node_in_group("player")
	get_tree().create_timer(lifetime).timeout.connect(_on_lifetime_timeout)

func set_initial_direction(dir: Vector2):
	velocity = dir

func _physics_process(delta):
	if not GameManager.is_game_active:
		return

	if target and is_instance_valid(target):
		var to_target = (target.global_position - global_position).normalized()
		velocity = velocity.lerp(to_target, turn_speed * delta).normalized()
		
	position += velocity * speed * delta
	rotation = velocity.angle()

func _on_body_entered(body):
	_check_collision(body)

func _on_area_entered(area):
	_check_collision(area)

func _check_collision(object):
	if object.is_in_group("player"):
		var life_bar = get_tree().current_scene.find_child("LifeBar", true, false)
		if life_bar and life_bar.has_method("lose_life"):
			life_bar.lose_life()
		die()
	elif object.is_in_group("environment") or object.is_in_group("player_projectiles"):
		die()

func _on_lifetime_timeout():
	die()

func die():
	_spawn_explosion()
	
	queue_free()

func _spawn_explosion():
	if explosion_scene:
		var explosion = explosion_scene.instantiate()
		get_parent().add_child(explosion)
		explosion.global_position = global_position
		if explosion.has_method("play"):
			explosion.play("default")

func _play_sound():
	if hit_sound:
		var sound_player = AudioStreamPlayer.new()
		sound_player.stream = hit_sound
		get_tree().root.add_child(sound_player)
		sound_player.play()
		sound_player.finished.connect(sound_player.queue_free)
