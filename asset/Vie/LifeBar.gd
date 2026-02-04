extends TextureProgressBar

var max_life := 10
var current_life := max_life

func _ready():
	max_value = max_life
	value = current_life

func lose_life():
	current_life = max(current_life - 1, 0)
	value = current_life
	
	if current_life <= 0:
		var player_node = get_tree().get_first_node_in_group("player")
		if player_node:
			player_node.die()
			
func _input(event):
	if event is InputEventKey and event.pressed and event.keycode == KEY_Q:
		lose_life()
