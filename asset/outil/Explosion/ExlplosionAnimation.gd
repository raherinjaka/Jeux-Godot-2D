extends AnimatedSprite2D

@export var start_animation := "default"

func _ready():
	if sprite_frames.has_animation(start_animation):
		sprite_frames.set_animation_loop(start_animation, false)
		play(start_animation)

func _on_animation_finished():
	queue_free()
