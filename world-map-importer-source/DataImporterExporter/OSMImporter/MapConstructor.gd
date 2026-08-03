# ---------------------------------------------------------------------------------------------------------------------------------------
# ---------------------------------------------------------------------------------------------------------------------------------------
# Map Constructor
# ---------------------------------------------------------------------------------------------------------------------------------------
# ---------------------------------------------------------------------------------------------------------------------------------------
## Constructs the map out of the OSM data it's been given
class_name MapConstructor extends RefCounted

# ---------------------------------------------------------------------------------------------------------------------------------------
# Constants
# ---------------------------------------------------------------------------------------------------------------------------------------
const RADIUS_OF_EARTH = 6371
const ItemLayers: Dictionary[String, int] = {
	"sea": 0,
	"land": 1,
	"builtupareas": 2,
	"names": 3
}

const LabelSizes: Dictionary[String, int] = {
	"country": 100,
	"island": 40,
	"city": 30,
	"town": 16,
	"village": 13,
	"hamlet": 9,
	"suburb": 9,
	"neighborhood": 5
}

var MapColours: Dictionary[String, Color] = {
	"sea": Color.from_rgba8(144, 218, 238),
	"land": Color.from_rgba8(69, 145, 106, 255),
	"builtupareas": Color.from_rgba8(246, 245, 245, 255)
}

# ---------------------------------------------------------------------------------------------------------------------------------------
# Member Variable Declaration
# ---------------------------------------------------------------------------------------------------------------------------------------
# Private Member Variables
var TopLeftReferencePoint: ReferencePoint
var BottomRightReferencePoint: ReferencePoint
var WorldMapVisualiser: Node2D
var LandmassVisualiser: Node2D
var BuiltUpAreasVisualiser: Node2D
var PlaceLabelsVisualiser: Node2D

# ---------------------------------------------------------------------------------------------------------------------------------------
# Constructor
# ---------------------------------------------------------------------------------------------------------------------------------------
func _init(_TopLeftReferencePoint: ReferencePoint, _BottomRightReferencePoint: ReferencePoint, _WorldMapVisualiser: Node2D):
	TopLeftReferencePoint = _TopLeftReferencePoint
	BottomRightReferencePoint = _BottomRightReferencePoint
	WorldMapVisualiser = _WorldMapVisualiser
	LandmassVisualiser = WorldMapVisualiser.get_node("Landmass")
	BuiltUpAreasVisualiser = WorldMapVisualiser.get_node("BuiltUpAreas")
	PlaceLabelsVisualiser = WorldMapVisualiser.get_node("PlaceLabels")
	
	# Setting the global X and Y's of the reference points
	var topLeftReferencePointGlobalXY = convert_long_lat_to_global_XY(TopLeftReferencePoint.Latitude, TopLeftReferencePoint.Longitude)
	TopLeftReferencePoint.GlobalX = topLeftReferencePointGlobalXY[0]
	TopLeftReferencePoint.GlobalY = topLeftReferencePointGlobalXY[1]
	
	var bottomRightReferencePointGlobalXY = convert_long_lat_to_global_XY(BottomRightReferencePoint.Latitude, BottomRightReferencePoint.Longitude)
	BottomRightReferencePoint.GlobalX = bottomRightReferencePointGlobalXY[0]
	BottomRightReferencePoint.GlobalY = bottomRightReferencePointGlobalXY[1]

# ---------------------------------------------------------------------------------------------------------------------------------------
# CODE
# ---------------------------------------------------------------------------------------------------------------------------------------
## Constructs the map and converts the longitude and latitude data into X and Y
func construct_map(input: Dictionary):
	# Creating the ocean
	var positionTopLeft = Vector2(TopLeftReferencePoint.ScreenX, TopLeftReferencePoint.ScreenY)
	var positionBottomRight = Vector2(BottomRightReferencePoint.ScreenX, BottomRightReferencePoint.ScreenY)
	positionBottomRight = (positionTopLeft - positionBottomRight).abs()
	var newSea: ColorRect = ColorRect.new()
	newSea.position = positionTopLeft
	newSea.size = positionBottomRight
	newSea.color = MapColours["sea"]
	WorldMapVisualiser.add_child(newSea)
	
	# Creating everything else
	for element: Dictionary in input["elements"]:
		# Constructing the landmasses, if their relations
		if element["type"] == "relation":
			var arrayOfVectors: PackedVector2Array = []
			var landmassFiller: Line2D = Line2D.new()
			for way in element["members"]:
				if way.has("geometry"):
					for positionalNode in way["geometry"]:
						var positionXY: Vector2 = convert_long_lat_to_screen_XY(positionalNode["lat"], positionalNode["lon"])
						if !arrayOfVectors.has(positionXY):
							arrayOfVectors.append(positionXY)
			arrayOfVectors = simplify_visvalingam(arrayOfVectors, arrayOfVectors.size()/5)
			var slicedLandmassGeometry = Geometry2D.merge_polygons(arrayOfVectors, PackedVector2Array([]))
			for landmassSliceGeometry in slicedLandmassGeometry:
				var newLandmassSlice: Polygon2D = Polygon2D.new()
				newLandmassSlice.set_polygon(landmassSliceGeometry)
				newLandmassSlice.color = MapColours["land"]
				newLandmassSlice.z_index = ItemLayers["land"]
				LandmassVisualiser.add_child(newLandmassSlice)	
			landmassFiller.points = arrayOfVectors
			landmassFiller.default_color = MapColours["land"]
			landmassFiller.z_index = ItemLayers["land"]
			landmassFiller.width = 0.02
			LandmassVisualiser.add_child(landmassFiller)
		
		# Constructing the landmasses, if their ways
		elif element["type"] == "way" && element["tags"].has("place"):
			var arrayOfVectors: Array[Vector2] = []
			arrayOfVectors = simplify_visvalingam(arrayOfVectors, arrayOfVectors.size()/20)
			for positionalNode in element["geometry"]:
				var positionXY: Vector2 = convert_long_lat_to_screen_XY(positionalNode["lat"], positionalNode["lon"])
				arrayOfVectors.append(positionXY)
			
			var newLandmass: Polygon2D = Polygon2D.new()
			newLandmass.set_polygon(arrayOfVectors)
			newLandmass.color = MapColours["land"]
			newLandmass.z_index = ItemLayers["land"]
			LandmassVisualiser.add_child(newLandmass)
		
		# Constructing the build up areas
		elif element["type"] == "way" && element.has("tags") && element["tags"].has("landuse"):
			var arrayOfVectors: Array[Vector2] = []
			for positionalNode in element["geometry"]:
				var positionXY: Vector2 = convert_long_lat_to_screen_XY(positionalNode["lat"], positionalNode["lon"])
				arrayOfVectors.append(positionXY)
			var newBuiltupArea: Polygon2D = Polygon2D.new()
			newBuiltupArea.set_polygon(arrayOfVectors)
			newBuiltupArea.color = MapColours["builtupareas"]
			newBuiltupArea.z_index = ItemLayers["builtupareas"]
			BuiltUpAreasVisualiser.add_child(newBuiltupArea)
			
		# Constructing the place labels
		elif element["type"] == "node" && element.has("tags") && element["tags"].has("place"):
			var newPlaceLabel: Label = Label.new()
			var positionXY: Vector2 = convert_long_lat_to_screen_XY(element["lat"], element["lon"])
			newPlaceLabel.position = positionXY
			newPlaceLabel.text = element["tags"]["name"]
			newPlaceLabel.z_index = ItemLayers["names"]
			newPlaceLabel.add_theme_color_override("font_color", Color.from_rgba8(0, 0, 0))
			newPlaceLabel.add_theme_font_size_override("font_size", LabelSizes[element["tags"]["place"]])
			PlaceLabelsVisualiser.add_child(newPlaceLabel)

## Converts longitude and latitude to a global X and Y that will later be scaled reference points and the screen XY
func convert_long_lat_to_global_XY(longitude : float, latitude : float) -> Vector2:
	var x = RADIUS_OF_EARTH * longitude * cos((TopLeftReferencePoint.Latitude + BottomRightReferencePoint.Latitude)/2)
	var y = RADIUS_OF_EARTH * latitude
	return Vector2(x, y)

## Converts the longitude and latitude to a scaled X and Y based on the reference points
func convert_long_lat_to_screen_XY(longitude : float, latitude : float) -> Vector2:
	var position: Vector2 = convert_long_lat_to_global_XY(longitude, latitude)
	var x = ((position.x-TopLeftReferencePoint.GlobalX)/(BottomRightReferencePoint.GlobalX - TopLeftReferencePoint.GlobalX))
	var y = ((position.y-TopLeftReferencePoint.GlobalY)/(BottomRightReferencePoint.GlobalY - TopLeftReferencePoint.GlobalY))
	
	x = TopLeftReferencePoint.ScreenX + (BottomRightReferencePoint.ScreenX - TopLeftReferencePoint.ScreenX) * x
	y = TopLeftReferencePoint.ScreenY + (BottomRightReferencePoint.ScreenY - TopLeftReferencePoint.ScreenY) * y
	
	return Vector2(y, x)
	

## Simplifies a polyline or polygon using Visvalingam–Whyatt.
## points: Array[Vector2]
## target_count: how many points you want to KEEP (not remove)
func simplify_visvalingam(points: Array[Vector2], target_count: int) -> Array[Vector2]:
	if points.size() <= target_count:
		return points.duplicate()

	# Each entry: { index, area }
	var areas := []
	for i in range(points.size()):
		areas.append({ "i": i, "area": _triangle_area(points, i) })

	# We repeatedly remove the point with the smallest effective area
	while areas.size() > target_count:
		# Find smallest non-endpoint area
		var min_idx := -1
		var min_area := INF

		for j in range(1, areas.size() - 1):
			var a = areas[j]["area"]
			if a < min_area:
				min_area = a
				min_idx = j

		# Remove that point
		areas.remove_at(min_idx)

		# Recompute areas of neighbors
		if min_idx - 1 >= 1:
			areas[min_idx - 1]["area"] = _triangle_area(points, areas[min_idx - 1]["i"])
		if min_idx < areas.size() - 1:
			areas[min_idx]["area"] = _triangle_area(points, areas[min_idx]["i"])

	# Return the surviving points in original order
	areas.sort_custom(func(a, b): return a["i"] < b["i"])
	var out: Array[Vector2] = []
	for entry in areas:
		out.append(points[entry["i"]])
	return out


# Computes the "effective area" of the triangle formed by (prev, current, next)
# Endpoints get infinite area so they are never removed.
func _triangle_area(points: Array, i: int) -> float:
	if i == 0 or i == points.size() - 1:
		return INF

	var a = points[i - 1]
	var b = points[i]
	var c = points[i + 1]

	return abs((a.x * (b.y - c.y) + b.x * (c.y - a.y) + c.x * (a.y - b.y)) * 0.5)
