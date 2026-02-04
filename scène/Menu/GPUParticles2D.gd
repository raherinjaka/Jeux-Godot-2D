extends GPUParticles2D

func _ready():
	while true:
		position = Vector2(randf_range(200, 900), randf_range(100, 400))
		restart()
		await get_tree().create_timer(1.2).timeout
