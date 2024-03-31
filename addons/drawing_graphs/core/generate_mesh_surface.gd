class_name GenerateMeshSurface

"""
-----
	Functionality to adds 3d surfaces to an existing mesh
	- generate surface array
	- append surface array to mesh

	Requires
		- Mesh
		- vertices
		- indices (optional)
		- draw mode (optional)
		- material (optional)
-----
"""		
static func generate_surface_array(vertices, indices = null) -> Array:
	# initialize surface array
	var surface_array = []
	surface_array.resize(ArrayMesh.ARRAY_MAX)

	# Assign surface arrays
	surface_array[Mesh.ARRAY_VERTEX] = vertices	
	
	if indices != null:
		surface_array[Mesh.ARRAY_INDEX] = indices
	return surface_array

static func append_surface_to_mesh(mesh, surface_array:Array, draw_mode:int = Mesh.PRIMITIVE_POINTS, material = null):
	# Create mesh surface from mesh array.
	mesh.add_surface_from_arrays(draw_mode, surface_array)

	if material != null:
		mesh.surface_set_material(mesh.get_surface_count() - 1, material)
 