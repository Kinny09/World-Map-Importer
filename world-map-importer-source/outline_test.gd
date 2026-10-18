extends MeshInstance2D

const arrayOfPoints: PackedVector2Array = [Vector2(6.375, -19.323), Vector2(109.375, 1.677), Vector2(56.375, 62.677),  Vector2(-81.625,90.677),  Vector2(-60.625,18.677),  Vector2(28.375,29.677), Vector2(6.375, -19.323)]

func _draw():
	draw_polyline(arrayOfPoints, Color.from_rgba8(18, 48, 33, 255), 5)
