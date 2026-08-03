extends Node

var polygons: Array[PackedVector2Array] = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var landmassesFile = FileAccess.open("res://RawMapData/WorldMapLandmassRaw.txt", FileAccess.READ)

	#while not landmassesFile.eof_reached():
	var previousShapeID = 0
	var previousPartID = 0
	var polygonPoints: PackedVector2Array = []

	# Setting up the the landmass polygons
	while !landmassesFile.eof_reached():
		var lineToRead = landmassesFile.get_line()
		var slicedLine = lineToRead.split(",")
		var currentShapeID = slicedLine[0].to_int()
		var currentPartID = slicedLine[1].to_int()
		
		if currentPartID != previousPartID || previousShapeID != currentShapeID:
			polygons.append(polygonPoints)
			polygonPoints = []
			var x = slicedLine[2].to_float()
			var y = slicedLine[3].to_float()
			polygonPoints.append(Vector2(x, -y))
		
		else:
			var x = slicedLine[2].to_float()
			var y = slicedLine[3].to_float()
			polygonPoints.append(Vector2(x, -y))
		
		previousShapeID = currentShapeID
		previousPartID = currentPartID
	
		
	# Constructing the polygons
	for landmassGeometry in polygons:
		var slicedLandmassGeometry = Geometry2D.merge_polygons(landmassGeometry, PackedVector2Array([]))
		for landmassSliceGeometry in slicedLandmassGeometry:
			var newPolygon = Polygon2D.new()
			newPolygon.set_polygon(landmassSliceGeometry)
			%WorldMapVisualiser.add_child(newPolygon)
		


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
