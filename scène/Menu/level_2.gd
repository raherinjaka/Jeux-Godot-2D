extends Node2D
@onready var sound = $CountdownSound
@onready var label = $CanvasLayer/CountdownLabel

func _ready():
	GameManager.stop_game()
	run_countdown()

func run_countdown():
	for i in range(3, 0, -1):
		label.text = str(i)
		
		sound.play()
		await get_tree().create_timer(0.8).timeout
		sound.stop()
		await get_tree().create_timer(0.2).timeout
	
	label.text = "GO!"
	sound.stop()
	
	await get_tree().create_timer(0.5).timeout
	label.hide()
	
	GameManager.start_game()
