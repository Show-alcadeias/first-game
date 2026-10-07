extends SceneTree

var failures: int = 0
var checks: int = 0
var game: Node2D


func _initialize() -> void:
	_run.call_deferred()


func check(condition: bool, description: String) -> void:
	checks += 1
	if not condition:
		failures += 1
		push_error("FAIL: " + description)


func press(action: String) -> void:
	var event := InputEventAction.new()
	event.action = action
	event.pressed = true
	game._unhandled_input(event)


func finish_dialogue() -> void:
	while not game.dialogue_lines.is_empty():
		press("interact")


func frames(count: int) -> void:
	for index in range(count):
		await physics_frame
	await process_frame


func _run() -> void:
	game = load("res://main.tscn").instantiate()
	root.add_child(game)
	current_scene = game
	await frames(3)
	check(game.quest_state == game.QuestState.NOT_STARTED, "quest starts unaccepted")
	check(game.herbs.size() == 9, "nine herbs are available")
	check(game.ui.count_label.text == "Herbs: 0 / 5", "initial herb UI")
	press("interact")
	check(game.dialogue_lines.is_empty(), "distant interactions do nothing")
	game.player.position = game.herbs[0].position
	press("interact")
	check(game.herb_count == 0 and not game.herbs[0].collected, "cannot collect before accepting quest")
	finish_dialogue()
	game.player.position = game.npc.position + Vector2(-48, 0)
	await frames(2)
	check(game.ui.prompt_label.text.contains("Talk"), "nearby NPC prompt")
	press("interact")
	check(game.ui.dialogue_panel.visible and not game.player.can_move, "dialogue displayed and movement paused")
	check(game.quest_state == game.QuestState.NOT_STARTED, "quest waits for dialogue end")
	finish_dialogue()
	check(game.quest_state == game.QuestState.IN_PROGRESS, "NPC starts quest after dialogue")
	press("interact")
	finish_dialogue()
	check(not game.game_completed, "insufficient herbs cannot complete quest")

	# Use actual input and physics steps, rather than inspecting speed constants.
	game.player.position = Vector2(600, 800)
	Input.action_press("move_right")
	await frames(20)
	check(game.player.position.x > 620, "right movement advances player")
	var straight_speed: float = game.player.velocity.length()
	Input.action_press("move_down")
	await frames(3)
	check(is_equal_approx(game.player.velocity.length(), straight_speed), "diagonal speed is normalized")
	Input.action_release("move_right")
	Input.action_release("move_down")

	await blocked(Vector2(640, 480), "move_up", 464, true, true, "tree collision")
	await blocked(Vector2(790, 760), "move_right", 812, false, false, "rock collision")
	await blocked(Vector2(1430, 730), "move_right", 1458, false, false, "pond collision")
	await blocked(Vector2(350, 800), "move_right", 374, false, false, "NPC collision")
	await blocked(Vector2(25, 800), "move_left", 12, false, true, "left boundary")
	await blocked(Vector2(2375, 800), "move_right", 2388, false, false, "right boundary")
	await blocked(Vector2(300, 25), "move_up", 12, true, true, "top boundary")
	await blocked(Vector2(300, 1575), "move_down", 1588, true, false, "bottom boundary")

	for index in range(6):
		var herb: Area2D = game.herbs[index]
		game.player.position = herb.position + Vector2(0, 30)
		await frames(2)
		check(game.ui.prompt_label.text.contains("Collect"), "herb interaction prompt %d" % index)
		press("interact")
		check(game.herb_count == index + 1 and not herb.visible, "herb disappears and count increases %d" % index)
		press("interact")
		check(game.herb_count == index + 1, "herb cannot be collected twice %d" % index)
	check(game.ui.count_label.text == "Herbs: 5 / 5", "visible count capped at five")
	check(game.ui.objective_label.text.contains("Return"), "objective requests return to camp")
	check(not game.game_completed, "five herbs alone do not complete quest")
	game.player.position = game.npc.position + Vector2(-48, 0)
	press("interact")
	check(not game.game_completed, "completion waits for thank-you dialogue")
	finish_dialogue()
	await frames(2)
	check(game.quest_state == game.QuestState.COMPLETED and game.game_completed, "NPC turn-in completes quest")
	check(game.herb_count == 1, "turn-in removes exactly five herbs")
	check(game.ui.completion_panel.visible, "completion screen visible")
	var final_position: Vector2 = game.player.position
	Input.action_press("move_left")
	await frames(5)
	Input.action_release("move_left")
	check(game.player.position.is_equal_approx(final_position), "movement stops after completion")
	press("restart")
	await frames(4)
	game = current_scene
	check(game.quest_state == game.QuestState.NOT_STARTED and game.herb_count == 0, "restart resets quest and inventory")
	check(not game.ui.completion_panel.visible and game.player.can_move, "restart restores gameplay")
	check(game.herbs.all(func(herb): return not herb.collected and herb.visible), "restart restores all herbs")
	print("Game tests: %d checks, %d failures" % [checks, failures])
	quit(1 if failures else 0)


func blocked(start: Vector2, action: String, limit: float, vertical: bool,
	minimum: bool, description: String) -> void:
	game.player.position = start
	Input.action_press(action)
	await frames(30)
	Input.action_release(action)
	var value: float = game.player.position.y if vertical else game.player.position.x
	check(value >= limit - 1 if minimum else value <= limit + 1, description)
	check(game.player.position.distance_to(start) > 5, description + " allows movement up to obstacle")