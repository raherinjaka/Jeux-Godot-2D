extends Control

@onready var musique = $AudioStreamPlayer2D
func _ready():
	musique.play(3.0)

func _process(delta):
	pass


func _on_quit_pressed():
	Transition.change_scene("res://scène/Menu/MenuSpacial.tscn")


func _on_start_pressed():
	Transition.change_scene("res://stage/level_space.tscn")
