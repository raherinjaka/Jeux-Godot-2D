extends Node

var score : int = 0
const TARGET_SCORE = 20
var is_game_active : bool = false

var levels = [
	"res://scène/Menu/level_2.tscn",
	"res://stage/fin.tscn"
]
var current_level_index = 0
var locked : bool = false 

func add_score(points: int):
	score += points
	if score >= TARGET_SCORE and not locked:
		change_level()

func reset_score():
	score = 0

func change_level():
	locked = true 
	reset_score()
	
	var next_scene : String
	if current_level_index < levels.size():
		next_scene = levels[current_level_index]
		current_level_index += 1
	else:
		next_scene = "res://stage/fin.tscn"
	
	Transition.change_scene(next_scene)
	
	await get_tree().create_timer(1.0).timeout
	locked = false

func restart_game_from_zero():
	score = 0
	current_level_index = 0
	locked = false
	Transition.change_scene("res://stage/level_space.tscn")

func start_game():
	is_game_active = true

func stop_game():
	is_game_active = false
