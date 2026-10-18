# ---------------------------------------------------------------------------------------------------------------------------------------
# ---------------------------------------------------------------------------------------------------------------------------------------
# Scalable Mesh Instance 2D
# ---------------------------------------------------------------------------------------------------------------------------------------
# ---------------------------------------------------------------------------------------------------------------------------------------
## A class that handles the creation and manipulation of a 2D mesh when given a set of points. If, for whatever reason, the mesh cannot be triangulated, it will delete itself.
class_name ScalableMeshInstance2D extends MeshInstance2D

# ---------------------------------------------------------------------------------------------------------------------------------------
# Member Variable Declaration
# ---------------------------------------------------------------------------------------------------------------------------------------
# Standard Member Variables
var ListOfPointsForMesh: PackedVector2Array
var OutlinePoints: PackedVector2Array
var OutlineColour: Color
var OutlineWidth: float
var test: PackedVector2Array

# ---------------------------------------------------------------------------------------------------------------------------------------
# Constructor
# ---------------------------------------------------------------------------------------------------------------------------------------
## Constructs the polygon from the given array of Vector2's. Also sets a colour depending on what you give it.
func _init(_listOfPointsForMesh: PackedVector2Array, _meshColour: Color = Color.from_rgba8(255, 255, 255, 255), _zIndex: int = 0):
	# ----------------------------------------- Constructing the mesh -----------------------------------------
	var listOfPointTriangleIndexs = Geometry2D.triangulate_polygon(_listOfPointsForMesh)
	
	if listOfPointTriangleIndexs.size() == 0:
		self.queue_free()
		return
	
	var arrayOfTriangles: PackedVector2Array = []
	for triangleCount: int in listOfPointTriangleIndexs.size() / 3:
		var triangleStartIndex = triangleCount * 3
		var trianglePoint1 = _listOfPointsForMesh[listOfPointTriangleIndexs[triangleStartIndex]]
		var trianglePoint2 = _listOfPointsForMesh[listOfPointTriangleIndexs[triangleStartIndex + 1]]
		var trianglePoint3 = _listOfPointsForMesh[listOfPointTriangleIndexs[triangleStartIndex + 2]]
		arrayOfTriangles.append(trianglePoint1)
		arrayOfTriangles.append(trianglePoint2)
		arrayOfTriangles.append(trianglePoint3)
	
	var intermidateArray = []
	intermidateArray.resize(Mesh.ARRAY_MAX)
	intermidateArray[Mesh.ARRAY_VERTEX] = arrayOfTriangles
	
	var arrayMesh = ArrayMesh.new()
	arrayMesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, intermidateArray)
	self.mesh = arrayMesh
	
	# ----------------------------------------- Setting the mesh properties -----------------------------------------
	self.modulate = _meshColour
	self.z_index = _zIndex
	ListOfPointsForMesh = _listOfPointsForMesh.duplicate()
	
# ---------------------------------------------------------------------------------------------------------------------------------------
# CODE
# ---------------------------------------------------------------------------------------------------------------------------------------
func change_mesh_colour(newMeshColour: Color):
	self.modulate = newMeshColour

func change_z_index(newZIndex: int):
	self.z_index = newZIndex
	
func add_outline_to_mesh(outlineColour: Color = Color.from_rgba8(255, 255, 255, 255), outlineWidth: float = 1.0):
	if ListOfPointsForMesh.size() >= 2:
		OutlinePoints = ListOfPointsForMesh.duplicate()
		OutlinePoints.append(ListOfPointsForMesh[0])
		
		OutlineColour = outlineColour
		OutlineWidth = outlineWidth
		queue_redraw()
	
func _draw():
	if ListOfPointsForMesh.size() >= 2:
		draw_polyline(ListOfPointsForMesh, OutlineColour, OutlineWidth)
	
