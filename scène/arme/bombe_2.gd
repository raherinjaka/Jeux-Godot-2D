extends Area2D

@export var speed := 400.0
var direction := Vector2.DOWN

@onready var explosion_scene = preload("res://asset/outil/Explosion/exlplosion_animation.tscn")
@onready var hit_sound = preload("res://asset/Sound/explosion.ogg") 

func _ready():
	add_to_group("player_projectiles")

func _physics_process(delta):
	global_position += direction * speed * delta

func _on_body_entered(body):
	if body.is_in_group("player"):
		return 
		
	if body.is_in_group("enemy") or "Turret" in body.name:
		if body.has_method("die"):
			body.die()
		else:
			body.queue_free()
		
		queue_free()
		
	elif body.is_in_group("environment"):
		_spawn_explosion()
		queue_free()

func _spawn_explosion():
	if explosion_scene:
		var explosion = explosion_scene.instantiate()
		get_parent().add_child(explosion)
		explosion.global_position = global_position
		
func _on_area_entered(area):
	if area.is_in_group("player"):
		return
		
	if area.is_in_group("enemy_projectiles"):
		_play_explosion_sound()
		area.queue_free()
		_spawn_explosion()
		queue_free()
		return
	
	if area.is_in_group("enemy"):
		if area.has_method("die"):
			area.die()
		_spawn_explosion()
		queue_free()

func _play_explosion_sound():
	if hit_sound:
		var sound_player = AudioStreamPlayer2D.new()
		sound_player.stream = hit_sound
		
		get_tree().current_scene.add_child(sound_player)
		sound_player.global_position = global_position
		
		sound_player.play()
		sound_player.finished.connect(sound_player.queue_free)
