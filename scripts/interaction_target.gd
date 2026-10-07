extends Area2D

var is_npc: bool = false
var collected: bool = false
var highlighted: bool = false


func _ready() -> void:
	collision_layer = 0
	collision_mask = 0
	var area_shape := CollisionShape2D.new()
	var circle := CircleShape2D.new()
	circle.radius = 22.0
	area_shape.shape = circle
	add_child(area_shape)
	if is_npc:
		var body := StaticBody2D.new()
		var solid_shape := CollisionShape2D.new()
		var solid_circle := CircleShape2D.new()
		solid_circle.radius = 14.0
		solid_shape.shape = solid_circle
		body.add_child(solid_shape)
		add_child(body)


func _draw() -> void:
	if highlighted:
		draw_arc(Vector2.ZERO, 30, 0, TAU, 32, Color("f0d893"), 2, true)
	if is_npc:
		draw_circle(Vector2(0, 12), 17, Color(0.05, 0.1, 0.08, 0.25))
		draw_rect(Rect2(-13, -13, 26, 27), Color("d6ab55"))
		draw_circle(Vector2(0, -19), 10, Color("efd4ac"))
		draw_line(Vector2(-12, -27), Vector2(12, -27), Color("815a38"), 6)
	else:
		draw_circle(Vector2.ZERO, 21, Color(0.45, 0.75, 0.3, 0.15))
		draw_line(Vector2(0, 9), Vector2(0, -15), Color("bdd985"), 3)
		for offset in [-9.0, 1.0]:
			draw_colored_polygon(PackedVector2Array([Vector2(0, offset),
				Vector2(-14, offset - 10), Vector2(-12, offset + 1)]), Color("9cd86e"))
			draw_colored_polygon(PackedVector2Array([Vector2(0, offset + 4),
				Vector2(14, offset - 5), Vector2(12, offset + 7)]), Color("c0e78d"))