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

# ---------------------------------------------------------------------------------------------------------------------------------------
# Constructor
# ---------------------------------------------------------------------------------------------------------------------------------------
func _init(_listOfPointsForMesh: PackedVector2Array):
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
	
# ---------------------------------------------------------------------------------------------------------------------------------------
# CODE
# ---------------------------------------------------------------------------------------------------------------------------------------
