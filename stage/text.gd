extends Label


func _ready():
	pivot_offset = size / 2
	scale = Vector2(0, 0)
	var tween = create_tween()
	
	tween.tween_property(self, "scale", Vector2(1, 1), 0.6)\
		.set_trans(Tween.TRANS_BACK)\
		.set_ease(Tween.EASE_OUT)

