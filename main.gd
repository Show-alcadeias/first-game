extends Node2D

const Player = preload("res://scripts/player.gd")
const World = preload("res://scripts/world.gd")
const InteractionTarget = preload("res://scripts/interaction_target.gd")
const GameUI = preload("res://scripts/game_ui.gd")
const REQUIRED_HERBS := 5
const INTERACTION_DISTANCE := 64.0
const HERB_POSITIONS: Array[Vector2] = [
	Vector2(720, 650),
	Vector2(1040, 400),
	Vector2(1250, 760),
	Vector2(1810, 400),
	Vector2(2150, 700),
	Vector2(1750, 1100),
	Vector2(1150, 1200),
	Vector2(800, 1280),
	Vector2(2100, 1400),
]

enum QuestState {
	NOT_STARTED,
	IN_PROGRESS,
	COMPLETED,
}

var quest_state := QuestState.NOT_STARTED
var herb_count := 0
var game_completed := false
var dialogue_lines: Array[String] = []
var player: CharacterBody2D
var npc: Area2D
var herbs: Array[Area2D] = []
var ui: CanvasLayer
var _dialogue_result := QuestState.NOT_STARTED


func _ready() -> void:
	_setup_input()
	add_child(World.new())
	npc = InteractionTarget.new()
	npc.is_npc = true
	npc.position = Vector2(400, 800)
	add_child(npc)
	for location in HERB_POSITIONS:
		var herb := InteractionTarget.new()
		herb.position = location
		add_child(herb)
		herbs.append(herb)
	player = Player.new()
	player.position = Vector2(240, 840)
	add_child(player)
	ui = GameUI.new()
	add_child(ui)
	ui.restart_requested.connect(_restart)
	ui.quit_requested.connect(_quit)
	_update_quest()


func _setup_input() -> void:
	var bindings := {
		"move_left": [KEY_A, KEY_LEFT],
		"move_right": [KEY_D, KEY_RIGHT],
		"move_up": [KEY_W, KEY_UP],
		"move_down": [KEY_S, KEY_DOWN],
		"interact": [KEY_E],
		"restart": [KEY_R],
		"quit": [KEY_ESCAPE],
	}
	for action in bindings:
		if not InputMap.has_action(action):
			InputMap.add_action(action)
		for key in bindings[action]:
			var event := InputEventKey.new()
			event.physical_keycode = key
			if not InputMap.action_has_event(action, event):
				InputMap.action_add_event(action, event)


func _process(_delta: float) -> void:
	_update_prompt()


func _nearest_target() -> Area2D:
	var nearest: Area2D = null
	var distance := INTERACTION_DISTANCE
	var targets: Array[Area2D] = [npc]
	if quest_state == QuestState.IN_PROGRESS:
		targets.append_array(herbs)
	for target in targets:
		if target.collected:
			continue
		var target_distance := player.position.distance_to(target.position)
		if target_distance <= distance:
			distance = target_distance
			nearest = target
	return nearest


func _update_prompt() -> void:
	var target: Area2D = null
	if not game_completed and dialogue_lines.is_empty():
		target = _nearest_target()
	for candidate in herbs + [npc]:
		if candidate.highlighted != (candidate == target):
			candidate.highlighted = candidate == target
			candidate.queue_redraw()
	ui.set_prompt(
		"" if target == null else "E · Talk to herbalist" if target.is_npc else "E · Collect herb"
	)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_echo():
		return
	if game_completed:
		if event.is_action_pressed("restart"):
			_restart()
		elif event.is_action_pressed("quit"):
			_quit()
	elif event.is_action_pressed("interact"):
		if not dialogue_lines.is_empty():
			_advance_dialogue()
		else:
			var target := _nearest_target()
			if target == npc:
				_talk()
			elif target != null:
				target.collected = true
				target.hide()
				herb_count += 1
				_update_quest()
		_update_prompt()


func _talk() -> void:
	_dialogue_result = quest_state
	if quest_state == QuestState.NOT_STARTED:
		dialogue_lines.assign(
			[
				"Welcome! I need five medicinal herbs from the forest.",
				"Find the bright green plants, then bring five herbs back to me.",
			]
		)
		_dialogue_result = QuestState.IN_PROGRESS
	elif herb_count < REQUIRED_HERBS:
		dialogue_lines.assign(
			["Please bring five medicinal herbs. You have %d so far." % herb_count]
		)
	else:
		dialogue_lines.assign(
			["These herbs are just what I needed. Thank you!", "You have helped everyone at camp."]
		)
		_dialogue_result = QuestState.COMPLETED
	player.can_move = false
	player.velocity = Vector2.ZERO
	ui.show_dialogue(dialogue_lines[0])


func _advance_dialogue() -> void:
	dialogue_lines.pop_front()
	if not dialogue_lines.is_empty():
		ui.show_dialogue(dialogue_lines[0])
		return
	ui.hide_dialogue()
	quest_state = _dialogue_result
	if quest_state == QuestState.COMPLETED:
		herb_count -= REQUIRED_HERBS
		game_completed = true
		ui.show_completion()
	player.can_move = not game_completed
	_update_quest()


func _update_quest() -> void:
	var objective := "Talk to the herbalist at camp."
	if quest_state == QuestState.IN_PROGRESS:
		objective = "Return to the herbalist." if herb_count >= REQUIRED_HERBS else "Collect five medicinal herbs."
	elif quest_state == QuestState.COMPLETED:
		objective = "Quest complete!"
	ui.update_quest(objective, herb_count, REQUIRED_HERBS)


func _restart() -> void:
	if game_completed:
		get_tree().reload_current_scene()


func _quit() -> void:
	if game_completed:
		get_tree().quit()
