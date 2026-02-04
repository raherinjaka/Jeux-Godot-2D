extends CanvasLayer

func _ready():
	hide()
	
func _on_quit_pressed():
	Transition.change_scene("res://stage/level_space.tscn")
	GameManager.reset_score()
	
	if get_tree():
		get_tree().paused = false
		GameManager.reset_score()
		get_tree().reload_current_scene()

func _on_restart_pressed():
	
	get_tree().paused = false
	GameManager.reset_score()
	Transition.change_scene("res://scène/Menu/MenuSpacial.tscn")
	
func show_game_over():
	show()
	
	if has_node("FinalScoreLabel"):
		$FinalScoreLabel.text = "SCORE : " + str(GameManager.score)
	else:
		print("ERREUR: Le noeud FinalScoreLabel est introuvable")

