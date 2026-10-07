extends CharacterBody2D

const SPEED: float = 160.0
var can_move: bool = true


func _ready() -> void:
	var collider := CollisionShape2D.new()
	var shape := CircleShape2D.new()
	shape.radius = 12.0
	collider.shape = shape
	add_child(collider)
	var camera := Camera2D.new()
	camera.position_smoothing_enabled = true
	camera.position_smoothing_speed = 8.0
	camera.limit_left = 0
	camera.limit_top = 0
	camera.limit_right = 2400
	camera.limit_bottom = 1600
	add_child(camera)


func _physics_process(_delta: float) -> void:
	var direction := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	velocity = direction * SPEED if can_move else Vector2.ZERO
	move_and_slide()


func _draw() -> void:
	draw_circle(Vector2(0, 12), 15, Color(0.05, 0.1, 0.08, 0.25))
	draw_rect(Rect2(-12, -15, 24, 28), Color("477cbb"))
	draw_rect(Rect2(-12, 1, 24, 12), Color("305780"))
	draw_circle(Vector2(0, -17), 9, Color("efd4ac"))
	draw_line(Vector2(-6, -23), Vector2(7, -23), Color("38566b"), 5)