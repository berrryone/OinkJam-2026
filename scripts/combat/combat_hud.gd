extends Node2D

var ref_world : Node2D
var pattern_spawner: Node2D

var combat_patterns = preload("res://scenes/combat/combat_pattern_ui.tscn")

var enemy_prefab = preload("res://scenes/combat/combat_enemy_prefab.tscn")
var enemy_sprite
var enemy_instance

var reaction_text_prefab = preload("res://scenes/UI/tween_label.tscn")

var combat_score: float
var combat_score_mod: float
var scoring_multiplier: float
var b_show_multiplier: bool
var b_adding_score: bool
var score_adding_delay: float
var score_adding_time: float

var weapon_damage: float
var enemy_health: float
var player_health: float
var b_enemy_damaged: bool

@export var combat_score_label: Label
@export var combat_score_mod_label: Label
@export var multiplier_label: Label
@export var enemy_start_pos: Vector2
@export var enemy_end_pos: Vector2
@export var enemy_intro_time: float
@export var reaction_text_start_pos: Vector2
@export var reaction_text_end_pos: Vector2
@export var reaction_text_color: Color
@export var reaction_text_fade_to: float
@export var reaction_text_anim_time: float

func _ready() -> void:
	enemy_sprite = load(Globals.combat_enemy_sprites["test"])
	enemy_instance = enemy_prefab.instantiate()
	add_child(enemy_instance)
	enemy_instance.hide()
	combat_score = 0.0
	combat_score_mod = 0.0
	scoring_multiplier = 1.0
	b_show_multiplier = false
	b_adding_score = false
	weapon_damage = 10.0
	enemy_health = 1200.0
	player_health = 1200.0
	score_adding_delay = 0.01
	score_adding_time = 0.0
	b_enemy_damaged = false

	# signals
	Globals.game_controller.new_game_started.connect(handle_new_game)
	Globals.game_controller.combat_input_pressed.connect(handle_combat_input)
	Globals.game_controller.combat_started.connect(start_pattern_scroll)
	Globals.game_controller.combat_ended.connect(stop_pattern_scroll)

func _process(delta: float) -> void:
	if b_adding_score:
		if combat_score_mod > 1:
			if score_adding_time >= score_adding_delay:
				combat_score = combat_score + 1
				combat_score_mod = combat_score_mod - 1
				update_score_mod()
				update_score_label()
				score_adding_time = 0.0
			else:
				score_adding_time = score_adding_time + delta
		else: 
			hide_score_mod()
			b_adding_score = false
	
	if b_show_multiplier:
		update_multiplier()

func handle_new_game() -> void:
	delete_pattern_spawner()
	enemy_instance.position = enemy_start_pos
	enemy_instance.hide()

# input (combat only)
func handle_combat_input(input: String) -> void:
	pattern_spawner.check_input(input)

# arrow pattern system
func start_pattern_scroll() -> void:
	if pattern_spawner == null:
		create_pattern_spawner()
		pattern_spawner.spawned_pattern.connect(on_pattern_spawned)
		
	pattern_spawner.reset()
	pattern_spawner.show()
	pattern_spawner.start_spawning()
	enemy_intro()

func stop_pattern_scroll() -> void:
	get_tree().create_timer(0.5).timeout.connect(func():
		if pattern_spawner != null:
			pattern_spawner.hide()
			pattern_spawner.stop_spawning()
	)

func handle_attack_success() -> void:
	if !b_enemy_damaged:
		damage_enemy()
		b_enemy_damaged = true

func handle_attack_fail() -> void:
	scoring_multiplier = 1

func create_pattern_spawner():
	if pattern_spawner == null:
		pattern_spawner = combat_patterns.instantiate()
		pattern_spawner.pattern_input_success.connect(handle_attack_success)
		pattern_spawner.pattern_input_failure.connect(handle_attack_fail)
		pattern_spawner.symbol_input_success_time2.connect(show_reaction_text)
		pattern_spawner.symbol_input_fail2.connect(show_reaction_text)
		add_child(pattern_spawner)
		pattern_spawner.hide()

func on_pattern_spawned() -> void:
	b_enemy_damaged = false # allows input again

func delete_pattern_spawner() -> void:
	stop_pattern_scroll()
	if pattern_spawner != null:
		pattern_spawner.queue_free()

# enemy - animations
func enemy_intro() -> void:
	enemy_instance.show()
	enemy_instance.texture = enemy_sprite
	enemy_instance.position = enemy_start_pos

	var tween = self.create_tween()
	tween.tween_property(enemy_instance, "position", enemy_end_pos, enemy_intro_time)
	await tween.finished

# show / animate / destroy reaction text to input time
func show_reaction_text(input_time: float = Globals.combat_input_precision.nope + 1) -> void:
	if !b_enemy_damaged:
		var b_scored: bool = false
		var reaction_label: Label = reaction_text_prefab.instantiate()
		reaction_label.position = reaction_text_start_pos
		reaction_label.label_settings.font_size = 42

		if input_time < Globals.combat_input_precision.superb:
			reaction_label.text = "Superb!!"
			reaction_label.label_settings.font_color = Color(0.6, 0.05, 0.8, 1.0)
			scoring_multiplier = scoring_multiplier + 0.2
			b_scored = true
		elif input_time < Globals.combat_input_precision.great:
			reaction_label.text = "Great!"
			reaction_label.label_settings.font_color = Color(0.1, 0.5, 0.9, 1.0)
			scoring_multiplier = scoring_multiplier + 0.1
			b_scored = true
		elif input_time < Globals.combat_input_precision.good:
			reaction_label.text = "Good!"
			reaction_label.label_settings.font_color = Color(0.2, 1.0, 0.2, 1.0)
			scoring_multiplier = scoring_multiplier + 0.05
			b_scored = true
		elif input_time < Globals.combat_input_precision.sure:
			reaction_label.text = "Sure."
			reaction_label.label_settings.font_color = Color(0.8, 0.8, 0.0, 1.0)
			scoring_multiplier = 1.0
			b_scored = true
		elif input_time < Globals.combat_input_precision.nope:
			reaction_label.text = "nope"
			reaction_label.label_settings.font_color = Color(0.8, 0.5, 0.0, 1.0)
			scoring_multiplier = 1.0
			b_scored = false
		else:
			reaction_label.text = "Fail"
			reaction_label.label_settings.font_color = Color(1.0, 0.0, 0.0, 1.0)
			scoring_multiplier = 1.0
			b_scored = false

		if scoring_multiplier > 1.0:
			b_show_multiplier = true
		else: b_show_multiplier = false
		if scoring_multiplier >= 50:
			scoring_multiplier = 50

		@warning_ignore("integer_division")
		if b_scored:
			combat_score_mod = combat_score_mod + (weapon_damage * scoring_multiplier)
		if combat_score_mod > 100.0:
			b_adding_score = true

		add_child(reaction_label)

		var tween = reaction_label.create_tween()
		tween.tween_property(reaction_label, "position", reaction_text_end_pos, reaction_text_anim_time)
		tween.tween_property(reaction_label, "modulate:a", reaction_text_fade_to, reaction_text_anim_time)
		await tween.finished
		reaction_label.queue_free()

func damage_enemy() -> void:
	var shake = enemy_instance.create_tween()
	var shake_dist = Vector2(8.0, 0.0)
	var shake_step = 0.02
	shake.tween_property(enemy_instance, "position", shake_dist, shake_step).as_relative()
	shake.tween_property(enemy_instance, "position", -shake_dist * 2, shake_step).as_relative()
	shake.tween_property(enemy_instance, "position", shake_dist * 2, shake_step).as_relative()
	shake.tween_property(enemy_instance, "position", -shake_dist * 2, shake_step).as_relative()
	shake.tween_property(enemy_instance, "position", shake_dist * 2, shake_step).as_relative()
	shake.tween_property(enemy_instance, "position", -shake_dist, shake_step).as_relative()

	print("damaged enemy with epic attack move")


# display / animate score / multiplier
func update_score_label() -> void:
	var score = round(combat_score)
	combat_score_label.text = "Score: " + str(score)
	if !combat_score_label.visible: combat_score_label.show()

func update_score_mod() -> void: # shows the label if hidden
	var mod = round(combat_score_mod)
	combat_score_mod_label.text = "Score: " + str(mod)
	if !combat_score_mod_label.visible: combat_score_mod_label.show()

func hide_score_mod() -> void:
	if combat_score_mod_label.visible: combat_score_mod_label.hide()

func update_multiplier() -> void:
	var color: Color = Color(1.0, 0.0, 0.0, 1.0)
	var t_scale: Vector2 = Vector2.ONE
	match scoring_multiplier:
		_ when scoring_multiplier > 1 and scoring_multiplier <= 3:
			color = Color(0.8, 0.5, 0.0, 1.0)
			t_scale = Vector2.ONE
		_ when scoring_multiplier > 3 and scoring_multiplier <= 7:
			color = Color(0.8, 0.8, 0.0, 1.0)
			t_scale = Vector2(1.1, 1.1)
		_ when scoring_multiplier > 8 and scoring_multiplier <= 15:
			color = Color(0.2, 1.0, 0.2, 1.0)
			t_scale = Vector2(1.2, 1.2)
		_ when scoring_multiplier > 15 and scoring_multiplier <= 25:
			color = Color(0.1, 0.5, 0.9, 1.0)
			t_scale = Vector2(1.3, 1.3)
		_ when scoring_multiplier > 50:
			color = Color(0.6, 0.05, 0.8, 1.0)
			t_scale = Vector2(1.5, 1.5)
	
	multiplier_label.text = str(scoring_multiplier) + "x"
	multiplier_label.label_settings.font_color = color
	if !multiplier_label.visible: multiplier_label.show()

func hide_multiplier() -> void:
	if multiplier_label.visible: multiplier_label.hide()
