# ---------------------------------------------------------------------------------------------------------------------------------------
# ---------------------------------------------------------------------------------------------------------------------------------------
# Scalable Mesh Instance 2D
# ---------------------------------------------------------------------------------------------------------------------------------------
# ---------------------------------------------------------------------------------------------------------------------------------------
## 
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
		print("Invalid Shape")
		self.queue_free()
		return
	
	var testArray: PackedVector2Array = []
	for triangleCount: int in listOfPointTriangleIndexs.size() / 3:
		var triangleStartIndex = triangleCount * 3
		var trianglePoint1 = _listOfPointsForMesh[listOfPointTriangleIndexs[triangleStartIndex]]
		var trianglePoint2 = _listOfPointsForMesh[listOfPointTriangleIndexs[triangleStartIndex + 1]]
		var trianglePoint3 = _listOfPointsForMesh[listOfPointTriangleIndexs[triangleStartIndex + 2]]
		testArray.append(trianglePoint1)
		testArray.append(trianglePoint2)
		testArray.append(trianglePoint3)
	
	var arrays = []
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = testArray
	
	var arrayMesh = ArrayMesh.new()
	arrayMesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	self.mesh = arrayMesh
	
# ---------------------------------------------------------------------------------------------------------------------------------------
# CODE
# ---------------------------------------------------------------------------------------------------------------------------------------
