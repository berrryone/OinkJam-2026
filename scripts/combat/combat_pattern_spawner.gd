extends Node2D

var pattern_spawn_timer: Timer
var pattern_lib: Array

var pattern_spawn_delay: float # sec\
var pattern_scroll_speed: float

var pattern_idx: int
var b_active: bool
var b_success: bool

var attack_pattern_prefab = preload("res://scenes/combat/attack_pattern.tscn")
var ap_instance

var pattern_timer_visual = preload("res://scenes/combat/pattern_timer_visual.tscn")
var timer_visual: Node2D

signal pattern_input_success
signal pattern_input_failure
signal symbol_input_success_time2
signal symbol_input_fail2
signal spawned_pattern

# init
func _ready() -> void:
	# define attack pattern
	pattern_lib = [
		["left", "left", "up", "up"],
		["up", "right", "down"],
		["right", "right", "down", "down"]
	]

	# pattern settings
	pattern_spawn_delay = 3 	# time until next pattern spawns
	pattern_scroll_speed = 500
	pattern_idx = 0
	b_active = false
	b_success = false

	# init spawn timer
	pattern_spawn_timer = Timer.new()
	pattern_spawn_timer.wait_time = pattern_spawn_delay
	pattern_spawn_timer.one_shot = false
	pattern_spawn_timer.timeout.connect(spawn_pattern)

	# timer visual setup
	timer_visual = pattern_timer_visual.instantiate()
	timer_visual.hide()

func _process(_delta: float) -> void:
	var perc = pattern_spawn_timer.time_left / pattern_spawn_timer.wait_time
	if timer_visual != null:
		timer_visual.update(perc)

# pattern spawning
func start_spawning() -> void:
	add_child(timer_visual)
	add_child(pattern_spawn_timer)
	timer_visual.position = Vector2(950.0, 140.0)
	pattern_spawn_timer.start()
	b_active = true

func stop_spawning() -> void:
	pattern_spawn_timer.stop()
	if ap_instance != null:
		ap_instance.hide()
	timer_visual.hide()
	b_active = false

func spawn_pattern() -> void:
	pattern_idx = 0
	b_success = false
	timer_visual.show()

	if ap_instance != null:
		ap_instance.queue_free()

	if b_active:
		var selected_pattern = choose_next_pattern()
		ap_instance = attack_pattern_prefab.instantiate()
		ap_instance.symbol_input_success_time.connect(handle_symbol_input_success_time)
		ap_instance.symbol_input_fail.connect(handle_symbol_input_fail)
		ap_instance.set_pattern(pattern_lib[selected_pattern], pattern_scroll_speed, 50.0)
		add_child(ap_instance)
		ap_instance.position = Vector2(950.0, 0.0)
		ap_instance.show()
		ap_instance.start()
		spawned_pattern.emit()

# currently chooses a pattern randomly from the array defined in _ready
# but this will probably change so the player will select which pattern they want to use
func choose_next_pattern() -> int:
	return randi_range(0, pattern_lib.size() - 1)

# checks if input matches current symbol in the current pattern
func check_input(input: String) -> bool:
	if input == ap_instance.pattern[pattern_idx]:
		if pattern_idx == ap_instance.pattern.size() - 1:
			ap_instance.success(pattern_idx)
			pattern_input_success.emit()
			return true
		elif pattern_idx < ap_instance.pattern.size() - 1:
			ap_instance.success(pattern_idx)
			pattern_idx = pattern_idx + 1
			return true
	else:
		pattern_idx = 0
		b_success = false
		ap_instance.fail()
		pattern_input_failure.emit()
		return false
	return false

func reset() -> void:
	if ap_instance != null:
		ap_instance.fail()

func handle_symbol_input_success_time(input_time: float) -> void:
	symbol_input_success_time2.emit(input_time)

func handle_symbol_input_fail() -> void:
	symbol_input_fail2.emit()