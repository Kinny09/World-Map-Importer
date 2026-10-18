extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var testArray: PackedVector2Array = [Vector2(-16,-20), Vector2(15, -10), Vector2(9, 18), Vector2(-37, -1), Vector2(-17, -6), Vector2(-43, -8)]
	
	#var m = ScalableMeshInstance2D.new(testArray)
	
	
	#var arrayMesh = ArrayMesh.new()
	#var arrays = []
	#arrays.resize(Mesh.ARRAY_MAX)
	#arrays[Mesh.ARRAY_VERTEX] = testArray
	#
	## Create the Mesh.
	#arrayMesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLE_STRIP, arrays)
	#var m = MeshInstance2D.new()
	#m.mesh = arrayMesh
	#
	#self.add_child(m)
