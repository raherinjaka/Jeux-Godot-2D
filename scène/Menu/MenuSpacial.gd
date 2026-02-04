extends Control

func _on_start_pressed():
	Transition.change_scene("res://stage/level_space.tscn")

func _on_credit_pressed():
	Transition.change_scene("res://scène/Menu/credits.tscn")


func _on_quit_pressed():
	if OS.get_name() != "Web":
		get_tree().quit()
	else:
		get_tree().change_scene_to_file("res://scenes/main_menu.tscn")


func _on_commande_pressed():
	Transition.change_scene("res://scène/Menu/commande.tscn")
