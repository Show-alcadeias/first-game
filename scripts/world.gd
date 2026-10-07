extends Node2D

const MAP_SIZE := Vector2(2400, 1600)
const TREES: Array[Vector2] = [
	Vector2(640, 420), Vector2(760, 280), Vector2(910, 530), Vector2(1160, 230),
	Vector2(1320, 490), Vector2(1630, 200), Vector2(1790, 590), Vector2(2090, 300),
	Vector2(2280, 550), Vector2(970, 950), Vector2(650, 1020), Vector2(690, 1380),
	Vector2(1030, 1420), Vector2(1480, 1260), Vector2(1970, 1330), Vector2(2250, 1140),
	Vector2(1880, 950), Vector2(1410, 850), Vector2(500, 190), Vector2(370, 1270)
]
const ROCKS: Array[Vector2] = [Vector2(850, 760), Vector2(1200, 600),
	Vector2(2060, 1030), Vector2(1540, 1430), Vector2(570, 1200)]
const POND := Rect2(1470, 620, 230, 260)


func _ready() -> void:
	# Fixed scenery keeps the map small, reproducible, and free of asset dependencies.
	for location in TREES:
		_add_circle_body(location, 32)
	for location in ROCKS:
		_add_circle_body(location, 26)
	_add_rect_body(POND)
	for wall in [Rect2(-40, -40, 2480, 40), Rect2(-40, 1600, 2480, 40),
		Rect2(-40, 0, 40, 1600), Rect2(2400, 0, 40, 1600)]:
		_add_rect_body(wall)


func _add_circle_body(location: Vector2, radius: float) -> void:
	var body := StaticBody2D.new()
	body.position = location
	var collider := CollisionShape2D.new()
	var shape := CircleShape2D.new()
	shape.radius = radius
	collider.shape = shape
	body.add_child(collider)
	add_child(body)


func _add_rect_body(rect: Rect2) -> void:
	var body := StaticBody2D.new()
	body.position = rect.get_center()
	var collider := CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	shape.size = rect.size
	collider.shape = shape
	body.add_child(collider)
	add_child(body)


func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, MAP_SIZE), Color("506c47"))
	draw_rect(Rect2(0, 570, 510, 460), Color("8c9463"))
	var trail := PackedVector2Array([Vector2(180, 800), Vector2(590, 800),
		Vector2(1020, 690), Vector2(1330, 950), Vector2(1790, 1130), Vector2(2200, 800)])
	draw_polyline(trail, Color("7c8056"), 112, true)
	draw_polyline(trail, Color("99966a"), 80, true)
	# Decorative ground marks are deterministic, not generated gameplay content.
	for index in range(210):
		var point := Vector2(70 + (index * 137) % 2260, 60 + (index * 211) % 1480)
		draw_line(point, point + Vector2(3, -7), Color("617c50"), 2)
		draw_line(point + Vector2(4, 0), point + Vector2(7, -5), Color("617c50"), 2)
	draw_rect(POND.grow(12), Color("718261"))
	draw_rect(POND, Color("3d727a"))
	for index in range(6):
		var start := POND.position + Vector2(30, 32 + index * 37)
		draw_line(start, start + Vector2(130, 0), Color("669095"), 2)
	for location in ROCKS:
		draw_circle(location + Vector2(4, 6), 28, Color("3c503c"))
		draw_colored_polygon(PackedVector2Array([location + Vector2(-26, 10),
			location + Vector2(-20, -16), location + Vector2(8, -24),
			location + Vector2(27, -2), location + Vector2(18, 20)]), Color("87938b"))
	for location in TREES:
		draw_circle(location + Vector2(5, 8), 44, Color("3b563d"))
		draw_rect(Rect2(location + Vector2(-8, 0), Vector2(16, 35)), Color("785e42"))
		draw_circle(location + Vector2(0, -12), 40, Color("2c503e"))
		draw_circle(location + Vector2(-10, -23), 27, Color("3b6448"))
	# A tent and sign identify the departure point without blocking the route.
	draw_colored_polygon(PackedVector2Array([Vector2(130, 735), Vector2(210, 620),
		Vector2(290, 735)]), Color("d2b67c"))
	draw_colored_polygon(PackedVector2Array([Vector2(175, 735), Vector2(210, 660),
		Vector2(245, 735)]), Color("695f43"))
	draw_string(ThemeDB.fallback_font, Vector2(158, 585), "CAMP", HORIZONTAL_ALIGNMENT_LEFT, -1, 24, Color("eee5bc"))
	draw_rect(Rect2(545, 697, 7, 57), Color("735d41"))
	draw_rect(Rect2(515, 680, 120, 35), Color("cfb785"))
	draw_string(ThemeDB.fallback_font, Vector2(524, 704), "FOREST >", HORIZONTAL_ALIGNMENT_LEFT, -1, 16, Color("394b3c"))