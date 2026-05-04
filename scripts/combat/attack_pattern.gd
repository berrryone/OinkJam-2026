extends Node2D

var combat_arrow_prefab = preload("res://scenes/combat/combat_arrow.tscn")
var arrow_base
var arrow_hit
var arrows: Array
var arrow_size: float
var arrow_space: float
var fall_speed: float
var max_fall_dist: float
var pattern: Array
var symbol_input_time: float

signal symbol_input_success_time
signal symbol_input_fail

# load sprites into memory
func _ready() -> void:
	arrow_base = load("res://assets/UI/combat/arrow_base.png")
	arrow_hit = load("res://assets/UI/combat/arrow_hit.png")
	arrow_size = 64
	arrow_space = 10

func _process(delta: float) -> void:
	for arrow in arrows:
		var fall_dist = arrow.position.y - arrow.start_pos.y
		if fall_dist < max_fall_dist:
			arrow.position.y = arrow.position.y + (fall_speed * delta)
	symbol_input_time = symbol_input_time + delta

func start() -> void:
	for dir in pattern:
		var arrow_inst = combat_arrow_prefab.instantiate()
		arrows.append(arrow_inst)

	var start_positions = calc_start_positions()
	for i in range(0, arrows.size()):
		arrows[i].position = Vector2(start_positions[i], position.y + 32)
		arrows[i].texture = arrow_base
		add_child(arrows[i])
		arrows[i].set_dir(pattern[i])

func set_pattern(new_pattern: Array, pattern_fall_speed: float, max_pattern_fall_dist: float) -> void:
	pattern = new_pattern
	fall_speed = pattern_fall_speed
	max_fall_dist = max_pattern_fall_dist

func calc_start_positions() -> Array:
	var result: Array
	var space = arrow_space

	# it doesn't like integer division lol, too bad for godot
	@warning_ignore("integer_division")
	var imin = -(arrows.size() / 2)
	@warning_ignore("integer_division")
	var imax = arrows.size() / 2

	if arrows.size() % 2 != 0:
		imax = imax + 1
		for i in range(imin, imax):
			if i == imin:
				result.append(((i * arrow_size) - (arrow_size / 2)) + space)
			else:
				result.append(((i * arrow_size) + (space * (i + 1)) - (arrow_size / 2)) + space)
	else:
		for i in range(imin, imax):
			if i == imin:
				result.append((i * arrow_size))
			else:
				result.append(((i * arrow_size) + (space * (i + 1))) + space)
		
	return result

func success(idx: int) -> void:
	arrows[idx].texture = arrow_hit
	arrows[idx].b_hit = true
	arrows[idx].play_success_animation()
	symbol_input_success_time.emit(symbol_input_time)
	symbol_input_time = 0.0

func fail() -> void:
	symbol_input_fail.emit()
	for arrow in arrows:
		arrow.texture = arrow_base
		arrow.reset()