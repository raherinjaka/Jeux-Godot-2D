extends Button

@export var hover_scale: Vector2 = Vector2(1.1, 1.1)
@export var pressed_scale: Vector2 = Vector2(0.9, 0.9)
 
func _ready():
	pivot_offset = size / 2
	scale = Vector2(0, 0)
	var tween = create_tween()
	
	tween.tween_property(self, "scale", Vector2(1, 1), 0.6)\
		.set_trans(Tween.TRANS_BACK)\
		.set_ease(Tween.EASE_OUT)
		
	mouse_entered.connect(_button_enter)
	mouse_exited.connect(_button_exit)
	

	call_deferred("_init_pivot")
	
func _init_pivot():
	pivot_offset = size/2.0
	
func _button_enter():
	create_tween().tween_property(self, "scale", hover_scale, 0.1).set_trans(Tween.TRANS_SINE)

func _button_exit():
	create_tween().tween_property(self, "scale", Vector2.ONE, 0.1).set_trans(Tween.TRANS_SINE)
	

