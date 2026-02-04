extends CanvasLayer

@onready var animation: AnimationPlayer = $TransitionAnimation

func change_scene(target_path: String) -> void:
	animation.play("Transition_out")
	await animation.animation_finished
	
	get_tree().change_scene_to_file(target_path)
	
	animation.play_backwards("Transition_out")

