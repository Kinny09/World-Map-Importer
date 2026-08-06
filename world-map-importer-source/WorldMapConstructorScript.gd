# ---------------------------------------------------------------------------------------------------------------------------------------
# ---------------------------------------------------------------------------------------------------------------------------------------
# World Map Constructor
# ---------------------------------------------------------------------------------------------------------------------------------------
# ---------------------------------------------------------------------------------------------------------------------------------------
extends Node

# ---------------------------------------------------------------------------------------------------------------------------------------
# Constants
# ---------------------------------------------------------------------------------------------------------------------------------------
const LandmassFilePath = "res://RawMapData/WorldMapLandmassRaw.txt"
const BuiltUpAreaFilePath = "res://RawMapData/WorldMapBuiltUpAreasRaw.txt"
const SettlementLabelFilePath = "res://RawMapData/WorldMapLabelsRaw.txt"
const CountryLabelFilePath = "res://RawMapData/WorldMapCountryLabelsRaw.txt"
const MapLayers: Dictionary[String, int] = {
	"Sea": 0,
	"Landmass": 1,
	"CountryBorders": 2,
	"BuiltUpArea": 3,
	"SettlementLabels": 4,
	"CountryLabels": 5
}
const LabelSizes: Dictionary[String, int] = {
	"country": 60,
	"settlement": 60,
}
var MapColours: Dictionary[String, Color] = {
	"Sea": Color.from_rgba8(144, 218, 238),
	"Landmass": Color.from_rgba8(69, 145, 106, 255),
	"CountryBorders": Color.from_rgba8(18, 48, 33, 255),
	"BuiltUpArea": Color.from_rgba8(246, 245, 245, 255)
}
const ScreenSize: Vector4 = Vector4(171, 134, -171, -134)
const MapScale: int = 20

# ---------------------------------------------------------------------------------------------------------------------------------------
# Member Variable Declaration
# ---------------------------------------------------------------------------------------------------------------------------------------
var PolygonsToDraw: Array[PackedVector2Array] = []

# ---------------------------------------------------------------------------------------------------------------------------------------
# CODE
# ---------------------------------------------------------------------------------------------------------------------------------------
func _ready() -> void:
	# ----------------------------------------- Sorting out the landmasses -----------------------------------------
	var landmassesFile = FileAccess.open(LandmassFilePath, FileAccess.READ)
	var previousShapeID = 0
	var previousPartID = 0

	# Getting the landmass data from the file
	var polygonPoints: PackedVector2Array = []
	while !landmassesFile.eof_reached():
		var lineToRead = landmassesFile.get_line()
		var slicedLine = lineToRead.split(",")
		var currentShapeID = slicedLine[0].to_int()
		var currentPartID = slicedLine[1].to_int()
		
		if currentShapeID != previousShapeID || currentPartID != previousPartID:
			var newPolygon: ScalablePolygon = ScalablePolygon.new()
			newPolygon.set_polygon(polygonPoints)
			newPolygon.color = MapColours["Landmass"]
			newPolygon.z_index = MapLayers["Landmass"]
			newPolygon.split_polygon_up()
			%WorldMapVisualiser.get_node("Landmass").add_child(newPolygon)
			polygonPoints.clear()
			var x = slicedLine[2].to_float()
			var y = slicedLine[3].to_float()
			polygonPoints.append(Vector2(x, -y) * MapScale)
			
		elif previousPartID == currentPartID:
			var x = slicedLine[2].to_float()
			var y = slicedLine[3].to_float()
			polygonPoints.append(Vector2(x, -y) * MapScale )
		
		previousShapeID = currentShapeID
		previousPartID = currentPartID
		
		previousShapeID = currentShapeID
		previousPartID = currentPartID
	
	# ----------------------------------------- Sorting out the country borders -----------------------------------------
	var borderPoints: Array[Vector2] = []
	landmassesFile = FileAccess.open(LandmassFilePath, FileAccess.READ)
	while !landmassesFile.eof_reached():
		var lineToRead = landmassesFile.get_line()
		var slicedLine = lineToRead.split(",")
		var currentShapeID = slicedLine[0].to_int()
		var currentPartID = slicedLine[1].to_int()
		
		if currentShapeID != previousShapeID || currentPartID != previousPartID:
			var newBorder: Line2D = Line2D.new()
			newBorder.points = borderPoints
			newBorder.default_color = MapColours["CountryBorders"]
			newBorder.z_index = MapLayers["CountryBorders"]
			newBorder.width = MapScale / 20.0
			%WorldMapVisualiser.get_node("CountryBorders").add_child(newBorder)
			borderPoints.clear()
			var x = slicedLine[2].to_float()
			var y = slicedLine[3].to_float()
			borderPoints.append(Vector2(x, -y) * MapScale)
			
		elif previousPartID == currentPartID:
			var x = slicedLine[2].to_float()
			var y = slicedLine[3].to_float()
			borderPoints.append(Vector2(x, -y) * MapScale )
		
		previousShapeID = currentShapeID
		previousPartID = currentPartID
	
	# ----------------------------------------- Sorting out the built up areas -----------------------------------------
	var builtupAreasFile = FileAccess.open(BuiltUpAreaFilePath, FileAccess.READ)
	previousShapeID = 0
	polygonPoints = []
	while !builtupAreasFile.eof_reached():
		var lineToRead = builtupAreasFile.get_line()
		var slicedLine = lineToRead.split(",")
		var currentShapeID = slicedLine[0].to_int()
		
		if currentShapeID != previousShapeID:
			var newPolygon: ScalablePolygon = ScalablePolygon.new(true, Vector2(17, 30))
			newPolygon.set_polygon(polygonPoints)
			newPolygon.color = MapColours["BuiltUpArea"]
			newPolygon.z_index = MapLayers["BuiltUpArea"]
			newPolygon.split_polygon_up()
			%WorldMapVisualiser.get_node("BuiltUpArea").add_child(newPolygon)
			polygonPoints.clear()
			var x = slicedLine[1].to_float()
			var y = slicedLine[2].to_float()
			polygonPoints.append(Vector2(x, -y) * MapScale)
			
		elif previousShapeID == currentShapeID:
			var x = slicedLine[1].to_float()
			var y = slicedLine[2].to_float()
			polygonPoints.append(Vector2(x, -y) * MapScale )
			
		previousShapeID = currentShapeID
		
	
	# ----------------------------------------- Sorting out the settlement labels -----------------------------------------
	var settlementLabelFile = FileAccess.open(SettlementLabelFilePath, FileAccess.READ)
	while !settlementLabelFile.eof_reached():
		var lineToRead = settlementLabelFile.get_line()
		var slicedLine = lineToRead.split(",")
		
		if slicedLine.size() != 3:
			continue

		var x = slicedLine[0].to_float()
		var y = slicedLine[1].to_float()
		
		var newLabel: ScalableLabel = ScalableLabel.new()
		newLabel.ZoomLevelVisibleRange = Vector2i(17, 30)
		newLabel.set_anchors_preset(Control.PRESET_CENTER)
		newLabel.position = Vector2(x, -y)  * MapScale
		newLabel.text = slicedLine[2]
		newLabel.z_index = MapLayers["SettlementLabels"]
		newLabel.add_theme_font_size_override("font_size", LabelSizes["settlement"])
		%WorldMapVisualiser.get_node("SettlementLabels").add_child(newLabel)
		
	# ----------------------------------------- Sorting out the country labels -----------------------------------------
	var countryLabelFile = FileAccess.open(CountryLabelFilePath, FileAccess.READ)
	while !countryLabelFile.eof_reached():
		var lineToRead = countryLabelFile.get_line()
		var slicedLine = lineToRead.split(",")
		
		if slicedLine.size() != 3:
			continue
			
		var x = slicedLine[1].to_float()
		var y = slicedLine[2].to_float()
		
		var newLabel: ScalableLabel = ScalableLabel.new()
		newLabel.set_anchors_preset(Control.PRESET_CENTER)
		newLabel.grow_vertical = Control.GROW_DIRECTION_BOTH
		newLabel.grow_horizontal = Control.GROW_DIRECTION_BOTH
		newLabel.position = Vector2(x, -y)  * MapScale
		newLabel.text = slicedLine[0]
		newLabel.z_index = MapLayers["SettlementLabels"]
		%WorldMapVisualiser.get_node("CountryLabels").add_child(newLabel)
		
### Constructs all the polygons currently in PolygonsToDraw before emptying it
#func DrawPolygons(typeOfItemToDraw: String):
	#for polygonGeometry in PolygonsToDraw:
		#var slicedPolygonGeometry = Geometry2D.merge_polygons(polygonGeometry, PackedVector2Array([]))
		#for polygonSliceGeometry in slicedPolygonGeometry:
			#var newPolygon: ScalablePolygon = ScalablePolygon.new()
			#newPolygon.set_polygon(polygonSliceGeometry)
			#newPolygon.color = MapColours[typeOfItemToDraw]
			#newPolygon.z_index = MapLayers[typeOfItemToDraw]
			#%WorldMapVisualiser.get_node(typeOfItemToDraw).add_child(newPolygon)
	#PolygonsToDraw = []
	
func scale_xy_coordinates_to_screen(CoordinatesToScale: Vector2) -> Vector2:
	var scaledCoordinates: Vector2 = Vector2.ZERO
	scaledCoordinates.x = ScreenSize[0] + (ScreenSize[2] - ScreenSize[0]) * CoordinatesToScale.x
	scaledCoordinates.y = ScreenSize[1] + (ScreenSize[3]  - ScreenSize[1]) * CoordinatesToScale.y
	
	return scaledCoordinates
	
