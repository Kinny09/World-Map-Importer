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
	"BuiltUpArea": 2,
	"CountryLabels": 3,
	"SettlementLabels": 3
}
const LabelSizes: Dictionary[String, int] = {
	"country": 1,
	"settlement": 1,
}
var MapColours: Dictionary[String, Color] = {
	"Sea": Color.from_rgba8(144, 218, 238),
	"Landmass": Color.from_rgba8(69, 145, 106, 255),
	"BuiltUpArea": Color.from_rgba8(246, 245, 245, 255)
}


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
	var polygonPoints: PackedVector2Array = []

	# Getting the landmass data from the file
	while !landmassesFile.eof_reached():
		var lineToRead = landmassesFile.get_line()
		var slicedLine = lineToRead.split(",")
		var currentShapeID = slicedLine[0].to_int()
		var currentPartID = slicedLine[1].to_int()
		
		if currentPartID != previousPartID || previousShapeID != currentShapeID:
			PolygonsToDraw.append(polygonPoints)
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
	
	DrawPolygons("Landmass")
	
	# ----------------------------------------- Sorting out the built up areas -----------------------------------------
	var builtupAreasFile = FileAccess.open(BuiltUpAreaFilePath, FileAccess.READ)
	previousShapeID = 0
	polygonPoints = []
	while !builtupAreasFile.eof_reached():
		var lineToRead = builtupAreasFile.get_line()
		var slicedLine = lineToRead.split(",")
		var currentShapeID = slicedLine[0].to_int()
		
		if previousShapeID != currentShapeID:
			PolygonsToDraw.append(polygonPoints)
			polygonPoints = []
			var x = slicedLine[1].to_float()
			var y = slicedLine[2].to_float()
			polygonPoints.append(Vector2(x, -y))
			
		else:
			var x = slicedLine[1].to_float()
			var y = slicedLine[2].to_float()
			polygonPoints.append(Vector2(x, -y))
			
		previousShapeID = currentShapeID
			
	DrawPolygons("BuiltUpArea")
	
	# Sorting out the settlement labels
	var settlementLabelFile = FileAccess.open(SettlementLabelFilePath, FileAccess.READ)
	while !settlementLabelFile.eof_reached():
		var lineToRead = settlementLabelFile.get_line()
		var slicedLine = lineToRead.split(",")
		
		if slicedLine.size() != 3:
			continue

		var x = slicedLine[0].to_float()
		var y = slicedLine[1].to_float()
		
		var newLabel: Label = Label.new()
		newLabel.position = Vector2(x, -y)
		newLabel.text = slicedLine[2]
		newLabel.z_index = MapLayers["SettlementLabels"]
		newLabel.add_theme_font_size_override("font_size", MapLayers["SettlementLabels"])
		%WorldMapVisualiser.get_node("SettlementLabels").add_child(newLabel)
		
	## Sorting out the country labels
	#var countryLabelFile = FileAccess.open(CountryLabelFilePath, FileAccess.READ)
	#while !countryLabelFile.eof_reached():
		#var lineToRead = settlementLabelFile.get_line()
		#var slicedLine = lineToRead.split(",")
		#
		#if slicedLine.size() != 3:
			#continue
			#
		#var x = slicedLine[1].to_float()
		#var y = slicedLine[2].to_float()
		#
		#var newLabel: Label = Label.new()
		#newLabel.position = Vector2(x, -y)
		#newLabel.text = slicedLine[0]
		#newLabel.add_theme_font_size_override("size", MapLayers["CountryLabels"])
		#%WorldMapVisualiser.get_node("CountryLabels").add_child(newLabel)
		
		
		
## Constructs all the polygons currently in PolygonsToDraw before emptying it
func DrawPolygons(typeOfItemToDraw: String):
	for polygonGeometry in PolygonsToDraw:
		var slicedPolygonGeometry = Geometry2D.merge_polygons(polygonGeometry, PackedVector2Array([]))
		for polygonSliceGeometry in slicedPolygonGeometry:
			var newPolygon = Polygon2D.new()
			newPolygon.set_polygon(polygonSliceGeometry)
			newPolygon.color = MapColours[typeOfItemToDraw]
			newPolygon.z_index = MapLayers[typeOfItemToDraw]
			%WorldMapVisualiser.get_node(typeOfItemToDraw).add_child(newPolygon)
	PolygonsToDraw = []
	
