extends Node

var game_controller: GameController
var game_score: float
var game_score_mod: float
var combat_score: float

func _ready() -> void:
	game_score = 0.0
	game_score_mod = 0.0
	combat_score = 0.0

var hud_scene_lib: Array = [
	"res://scenes/main_menu.tscn",
	"res://scenes/UI/game_hud.tscn",
	"res://scenes/UI/combat_hud.tscn"
]

var level_scene_lib: Array = [
	"res://scenes/UI/menu_background.tscn",
	"res://scenes/dev_scene.tscn",
	"res://scenes/combat/combat_scene.tscn"
]

var combat_enemy_sprites: Dictionary = {
	"test": "res://assets/UI/combat/combat_enemy_ph.png"
}

# this determines what multiplier is added for score
# and also is an indication of the text that is displayed
# on the hud - the number is in seconds
var combat_input_precision: Dictionary = {
	"superb": 0.1,
	"great": 0.2,
	"good": 0.3,
	"sure": 0.5,
	"nope": 1.0
}

enum GameStates {
	main_menu,
	in_world,
	in_combat,
	game_over,
	game_win
}

enum HUDScenes {
	main_menu,
	game_hud,
	combat_hud
}

enum LevelScenes {
	menu_background,
	dev_scene,
	combat_scene
}