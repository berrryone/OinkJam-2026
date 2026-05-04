extends Node

var game_score: float
var game_score_mod: float
var b_adding_score: bool
var score_adding_delay: float
var score_adding_time: float

@export var game_score_label: Label
@export var game_score_mod_label: Label

func _ready() -> void:
	game_score = Globals.game_score
	game_score_mod = Globals.game_score_mod
	Globals.game_controller.combat_ended.connect(on_combat_ended)

func _process(delta: float) -> void:
	if game_score_mod > 10:
		b_adding_score = true
	if b_adding_score:
		var amt = game_score_mod * 0.1
		if score_adding_time >= score_adding_delay:
			if game_score_mod > amt:
				game_score = game_score + amt
				game_score_mod = game_score_mod - amt
				update_score_mod()
				update_score_label()
				score_adding_time = 0.0
		else:
			score_adding_time = score_adding_time + delta
			print(game_score_mod)
	else: 
		hide_score_mod()
		b_adding_score = false

func on_combat_ended() -> void:
	game_score_mod = Globals.combat_score
	Globals.combat_score = 0.0
	print(game_score_mod)

func update_score_label() -> void:
	var score: int = round(game_score)
	game_score_label.text = "Score: " + str(score)
	if !game_score_label.visible: game_score_label.show()

func update_score_mod() -> void: # shows the label if hidden
	var mod: int = round(game_score_mod)
	game_score_mod_label.text = str(mod)
	if !game_score_mod_label.visible: game_score_mod_label.show()

func hide_score_mod() -> void:
	if game_score_mod_label.visible: game_score_mod_label.hide()