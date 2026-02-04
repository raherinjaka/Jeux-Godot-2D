extends CharacterBody2D

@export var speed := 500.0

func _process(delta):
	var direction := Vector2.ZERO

	if Input.is_action_pressed("ui_up"):
		direction.y -= 1
	if Input.is_action_pressed("ui_down"):
		direction.y += 1
	if Input.is_action_pressed("ui_left"):
		direction.x -= 1
	if Input.is_action_pressed("ui_right"):
		direction.x += 1

	# Ici on n'utilise PAS move_and_slide(), on force la position
	position += direction.normalized() * speed * delta
