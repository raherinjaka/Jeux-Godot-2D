extends Area2D

@export var speed := 800
var direction := Vector2.RIGHT

@onready var explosion_scene := preload("res://asset/outil/Explosion/exlplosion_animation.tscn")
@onready var hit_sound := preload("res://asset/Sound/explosion.ogg")

func _ready():
	add_to_group("player_projectiles")
	connect("body_entered", _on_body_entered)

	$VisibleOnScreenNotifier2D.connect("screen_exited", _on_visible_on_screen_notifier_2d_screen_exited)
	
	if not hit_sound:
		push_warning("Son d'impact non trouvé!")
	
	top_level = true

func _physics_process(delta):
	global_position += direction * speed * delta
	
func _on_body_entered(body):

		if body.is_in_group("enemy_projectiles"):
			body.queue_free()
			
		elif body.is_in_group("enemy"):
			if body.has_method("lose_life"):
				body.lose_life()
			elif body.has_method("die"):
				body.die() 
			else:
				body.queue_free()
		queue_free()

func _on_area_2d_area_entered(area):
	if area.is_in_group("player"):
		return
	
	if area.is_in_group("enemy_projectiles"):
		_play_explosion_sound()
		area.queue_free()
		_spawn_explosion()
		queue_free()
		return
		
func _play_explosion_sound():
	if hit_sound:
		var sound_player = AudioStreamPlayer2D.new()
		sound_player.stream = hit_sound
		
		get_tree().current_scene.add_child(sound_player)
		sound_player.global_position = global_position
		
		sound_player.play()
		sound_player.finished.connect(sound_player.queue_free)
		
func _spawn_explosion():
	if explosion_scene:
		var explosion = explosion_scene.instantiate()
		get_parent().add_child(explosion)
		explosion.global_position = global_position

func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()



