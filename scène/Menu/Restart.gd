extends TextureButton

func _ready():
	pivot_offset = size / 2
	button_down.connect(_on_button_down)
	button_up.connect(_on_button_up)

func _on_button_down():
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2(0.9, 0.9), 0.05).set_trans(Tween.TRANS_QUAD)

func _on_button_up():
	var tween = create_tween()
	
