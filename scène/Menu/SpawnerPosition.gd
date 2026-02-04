extends Marker2D

@onready var enemy_scene = preload("res://scène/Enemy/ennemie_1.tscn")
@export var spawn_delay := 3.0
@export var max_enemies := 8

var timer: Timer

func _ready():
	# On crée le timer
	timer = Timer.new()
	add_child(timer)
	timer.wait_time = spawn_delay
	timer.one_shot = false # On s'assure qu'il boucle proprement
	timer.timeout.connect(_on_timer_timeout)
	timer.start()

func _on_timer_timeout():
	# 1. On vérifie si le jeu est actif
	if not GameManager.is_game_active:
		return
		
	# 2. On compte les ennemis
	var current_enemies = get_tree().get_nodes_in_group("enemy")
	
	# 3. On ne spawn que SI on n'a pas atteint le max
	if current_enemies.size() < max_enemies:
		spawn_one_enemy()

func spawn_one_enemy():
	if enemy_scene == null:
		return

	# On instancie l'ennemi
	var enemy = enemy_scene.instantiate()
	
	# Calcul de la position Y aléatoire (pour ne pas être sur une seule ligne)
	var screen_height = get_viewport_rect().size.y
	var random_y = randf_range(100, screen_height - 100)
	
	# On applique la position (X du marker, Y aléatoire)
	enemy.global_position = Vector2(global_position.x, random_y)
	
	# AJOUT À LA SCÈNE
	get_tree().current_scene.add_child(enemy)
	
	# On s'assure qu'il est bien dans le groupe pour le prochain comptage
	enemy.add_to_group("enemy")
