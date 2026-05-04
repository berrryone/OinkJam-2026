extends Node

var heart_prefab: PackedScene = preload("res://scenes/UI/health_bar_heart.tscn")
var hearts: Array

func _ready() -> void:
	var n_hearts:int = calc_num_hearts()
	for i in range(0, n_hearts):
		var heart_inst = heart_prefab.instantiate()
		add_child(heart_inst)
		heart_inst.position.x = i * 41
		hearts.append(heart_inst)
	update_hearts()

	Globals.game_controller.combat_input_pressed.connect(update_hearts)

func update_hearts(_input: String = "") -> void:
	var check_n_hearts = calc_num_hearts()
	if check_n_hearts > hearts.size():
		add_hearts(check_n_hearts - hearts.size())

	var hp = Globals.game_controller.player_health
	var heart_value = 400

	for i in range(0, hearts.size()):
		var heart = hearts[i] as AnimatedSprite2D
		var heart_hp = clamp(hp - (i * heart_value), 0, heart_value)
		var frame = 4
		if heart_hp >= heart_value:
			frame = 0
		elif heart_hp < heart_value && heart_hp >= heart_value * 0.75:
			frame = 1
		elif heart_hp < heart_value * 0.75 && heart_hp >= heart_value * 0.5:
			frame = 2
		elif heart_hp < heart_value * 0.5 && heart_hp >= heart_value * 0.25:
			frame = 3

		heart.frame = frame

func calc_num_hearts() -> int:
	@warning_ignore("narrowing_conversion")
	return (Globals.game_controller.player_max_health / Globals.game_controller.quarter_heart_value) / 4

func add_hearts(num: int) -> void:
	var idx = hearts.size()
	for i in range(0, num):
		var heart_inst = heart_prefab.instantiate()
		hearts.append(heart_inst)
		heart_inst.position.x = idx * 41
		add_child(heart_inst)
		idx += 1

func animate_take_damage() -> void:
	pass

func animate_heal() -> void:
	pass
