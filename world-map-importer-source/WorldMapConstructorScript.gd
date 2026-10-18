# ---------------------------------------------------------------------------------------------------------------------------------------
# ---------------------------------------------------------------------------------------------------------------------------------------
# World Map Constructor
# ---------------------------------------------------------------------------------------------------------------------------------------
# ---------------------------------------------------------------------------------------------------------------------------------------
extends Node

# ---------------------------------------------------------------------------------------------------------------------------------------
# Constants
# ---------------------------------------------------------------------------------------------------------------------------------------
const LandmassFilePath = "res://RawMapData/temp1-nodes.txt"
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
	"BuiltUpArea": Color.from_rgba8(246, 245, 245, 255),
	"LabelColours": Color.from_rgba8(0, 0, 0, 255)
}
const ScreenSize: Vector4 = Vector4(171, 134, -171, -134)
const MapScale: int = 20

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
		
		if slicedLine.size() == 4:
			var currentShapeID = slicedLine[0].to_int()
			var currentPartID = slicedLine[1].to_int()

			if currentPartID == previousPartID and currentShapeID == previousShapeID:
				var x: float = slicedLine[2].to_float()
				var y: float = slicedLine[3].to_float()
				polygonPoints.append(Vector2(x, -y) * MapScale)

			else:
				var newMesh: ScalableMeshInstance2D = ScalableMeshInstance2D.new(polygonPoints, MapColours["Landmass"], MapLayers["Landmass"])
				newMesh.name = "Country %s Part %s" % [previousShapeID, previousPartID]
				self.add_child(newMesh)
				polygonPoints.clear()
				
				var x: float = slicedLine[2].to_float()
				var y: float = slicedLine[3].to_float()
				polygonPoints.append(Vector2(x, -y) * MapScale)
				previousShapeID = currentShapeID
				previousPartID = currentPartID
	
	# ----------------------------------------- Sorting out the country borders -----------------------------------------
