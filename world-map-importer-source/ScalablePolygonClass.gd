# ---------------------------------------------------------------------------------------------------------------------------------------
# ---------------------------------------------------------------------------------------------------------------------------------------
# Scalable Polygon Class
# ---------------------------------------------------------------------------------------------------------------------------------------
# ---------------------------------------------------------------------------------------------------------------------------------------
## A polygon that automatically disappears/reappears depending on the zoom level, only performs this action when on screen
class_name ScalablePolygon extends Polygon2D

# ---------------------------------------------------------------------------------------------------------------------------------------
# Member Variable Declaration
# ---------------------------------------------------------------------------------------------------------------------------------------
# Exported Member Variables
@export var PolygonHides: bool
@export var BaseScale: int = 60
@export var ZoomLevelVisibleRange: Vector2i = Vector2i(1, 16)
# Standard Member Variables
var OnScreenNotifier: VisibleOnScreenNotifier2D = VisibleOnScreenNotifier2D.new()

# ---------------------------------------------------------------------------------------------------------------------------------------
# Node References
# ---------------------------------------------------------------------------------------------------------------------------------------
@onready var Camera = get_viewport().get_camera_2d()
@onready var ZoomLevel: int = 0

# ---------------------------------------------------------------------------------------------------------------------------------------
# Constructor
# ---------------------------------------------------------------------------------------------------------------------------------------
func _init(_PolygonHides = false, _ZoomLevelVisibleRange = Vector2i(1, 16)):
	PolygonHides = _PolygonHides
	ZoomLevelVisibleRange = _ZoomLevelVisibleRange
	
# ---------------------------------------------------------------------------------------------------------------------------------------
# CODE
# ---------------------------------------------------------------------------------------------------------------------------------------
func _ready() -> void:
	if PolygonHides:
		var polygonSize: Vector2 = get_polygon_bounding_box_size()
		var polygonPositon: Vector2 = find_top_left_corner()
		OnScreenNotifier.rect = Rect2(polygonPositon.x, polygonPositon.y, polygonSize.x, polygonSize.y)
		self.add_child(OnScreenNotifier)
		OnScreenNotifier.screen_entered.connect(func():
			update_polygon()
			Camera.ZOOM_LEVEL_CHANGED.connect(update_polygon)
		)
		OnScreenNotifier.screen_exited.connect(func():
			Camera.ZOOM_LEVEL_CHANGED.disconnect(update_polygon)
		)

## Updates the polygons visiblity
func update_polygon():
	ZoomLevel = Camera["ZoomLevel"]
	if ZoomLevel >= ZoomLevelVisibleRange[0] && ZoomLevel <= ZoomLevelVisibleRange[1]:
		self.self_modulate.a = 1
	else:
		self.self_modulate.a = 0
		
## Gets a the size of a bound box around the polygon
func get_polygon_bounding_box_size() -> Vector2:
	if polygon.size() == 0:
		return Vector2.ZERO
		
	var minumumPosition: Vector2 = polygon[0]
	var maximumPosition: Vector2 = polygon[0]
	
	for vertex in polygon:
		minumumPosition.x = min(minumumPosition.x, vertex.x)
		minumumPosition.y = min(minumumPosition.y, vertex.y)
		maximumPosition.x = max(maximumPosition.x, vertex.x)
		maximumPosition.y = max(maximumPosition.y, vertex.y)
		
	var size: Vector2 = maximumPosition - minumumPosition
	return size
	
## Splits the polygon up into seperate peices if there are overlapping verticies, this allows GODOT to render polygons with overlapping verticies
func split_polygon_up():
	var slicedPolygonGeometry = Geometry2D.merge_polygons(self.get_polygon(), PackedVector2Array([]))
	if slicedPolygonGeometry.size() > 1:
		var polygonsIndex: Array[PackedInt32Array]
		var polygonsVerticies: PackedVector2Array
		var polygonStartIndex: int = 0
		var polygonEndIndex: int = 0
		
		for polygonSliceVerticies in slicedPolygonGeometry:
			polygonStartIndex = polygonsVerticies.size()
			polygonEndIndex = polygonStartIndex + polygonSliceVerticies.size()
			
			var verticiesInPolygon: PackedInt32Array = []
			for i in range(polygonStartIndex, polygonEndIndex):
				verticiesInPolygon.append(i)
			polygonsIndex.append(verticiesInPolygon)
			polygonsVerticies.append_array(polygonSliceVerticies)
	
		self.set_polygons(polygonsIndex)
		self.set_polygon(polygonsVerticies)
			
## Finds the top left corner of the polygon
func find_top_left_corner() -> Vector2:
	var topLeft: Vector2 = polygon[0]
	for vertex in polygon:
		topLeft.x = min(topLeft.x, vertex.x)
		topLeft.y = min(topLeft.y, vertex.y)
	
	return topLeft
