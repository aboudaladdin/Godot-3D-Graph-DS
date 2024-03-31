@tool
class_name PointGraph3D 
extends MeshInstance3D

# modes
enum CURSOR_MODE {SELECT_POINTS, ADD_POINTS, DELETE_POINTS, LINK_POINTS, CUT_EDGES}
enum MODIFIER_MODE {NONE, CTRL, SHIFT, ALT}
var modifier_mode = MODIFIER_MODE.NONE

@export var auto_connect: bool = true:
	set(value):
		auto_connect = value
		
@export var selected_point_id: int = -1

@export var last_id: int 
@export var points:Dictionary

@export var clear_all: bool:
	set(value):
		clear_all = !clear_all
		clear_all = false
		_clear_mesh()

@export var graph_material: GraphMaterial

"""
-----
	Ready
-----
"""	
func _ready():
	last_id = 0

	if points == null:
		points = {}
	elif not points.is_empty():
		last_id = points.keys().back()
		_generate_mesh()
	
	if graph_material == null:
		graph_material = GraphMaterial.new()
		graph_material._reset_to_default()

"""
-----
	Select closest point
-----
"""
func select_point(center_cell:Vector3) -> void:
	# find closest point
	var closest_point = -1
	var closest_distance = 0

	for id in points.keys():
		var distance = points[id].position.distance_to(center_cell)
		if closest_point == -1 or distance < closest_distance:
			closest_point = id
			closest_distance = distance
	
	selected_point_id = closest_point
	_generate_mesh()

"""
-----
	Add point to graph
-----
"""
func add_point(center_cell:Vector3) -> void:
	# create new point
	var point = Point.new()
	point.id = last_id + 1
	point.position = center_cell

	# if auto_connect is enabled make connection from previous point to this point
	if auto_connect and selected_point_id != -1:
		if selected_point_id in points.keys():
			points[selected_point_id].connections.append(point.id)
			# add a reference
			point.connections_from.append(selected_point_id)

	points[point.id] = point
	last_id = point.id
	selected_point_id = last_id

	_generate_mesh()


"""
-----
	Delete closest point
-----
"""
func delete_point(center_cell:Vector3) -> void:
	var distance_threshold = 0.3
	
	# find closest point to cursor
	var closest_point = null
	var closest_distance = 0

	for id in points.keys():
		var distance = points[id].position.distance_to(center_cell)
		if closest_point == null or distance < closest_distance:
			closest_point = id
			closest_distance = distance

	# delete if inside range distance threshold
	if closest_distance < distance_threshold:
		# delete it's connections
		for connection_from in points[closest_point].connections_from:
			points[connection_from].connections.erase(closest_point)
			print("removing  connection from {0} to {1} ".format([connection_from, closest_point]))

		for connection_to in points[closest_point].connections:
			points[connection_to].connections_from.erase(closest_point)
			print("removing  connection from {0} to {1} ".format([closest_point, connection_to]))

		# delete it
		points.erase(closest_point)
		print("removing point {0}".format([closest_point]))

	_generate_mesh()

"""
-----
	Generate mesh pipeline
-----
"""
func _generate_mesh() -> void:
	mesh = ArrayMesh.new()

	if not is_inside_tree() or points.is_empty():
		return

	_generate_points_mesh()
	_generate_selected_points_mesh()
	_generate_edges_mesh()
	

"""
	Generate Points Mesh
"""		
func _generate_points_mesh() -> void:
	var verts = PackedVector3Array()

	for id in points.keys():
		verts.append(points[id].position)

	var surface_arr = GenerateMeshSurface.generate_surface_array(verts)
	GenerateMeshSurface.append_surface_to_mesh(mesh, surface_arr, Mesh.PRIMITIVE_POINTS, graph_material.default_point_material)

	# # initialize mesh data
	# var surface_array = []
	# surface_array.resize(ArrayMesh.ARRAY_MAX)

	# var verts = PackedVector3Array()

	# # add vertices, edges
	# for id in points.keys():
	# 	verts.append(points[id].position)

	# # Assign arrays to surface array.
	# surface_array[Mesh.ARRAY_VERTEX] = verts

	# # Create mesh surface from mesh array.
	# mesh.add_surface_from_arrays(Mesh.PRIMITIVE_POINTS, surface_array)
	# mesh.surface_set_material(mesh.get_surface_count() - 1, graph_material.default_point_material)
 

"""
-----
	Generate Selected Points Mesh
	- create selection on vertices
-----
"""		
func _generate_selected_points_mesh() -> void:
	if selected_point_id == -1 or selected_point_id not in points.keys():
		return

	var selected_verts = PackedVector3Array()

	selected_verts.append(points[selected_point_id].position)

	var surface_arr = GenerateMeshSurface.generate_surface_array(selected_verts)
	GenerateMeshSurface.append_surface_to_mesh(mesh, surface_arr, Mesh.PRIMITIVE_POINTS, graph_material.default_selected_point_material)

	# initialize mesh data
	# var surface_array = []
	# var selected_surface_array = []
	# selected_surface_array.resize(ArrayMesh.ARRAY_MAX)

	# var selected_verts = PackedVector3Array()

	# selected_verts.append(points[selected_point_id].position)
	 
	# # Assign arrays to surface array.
	# selected_surface_array[Mesh.ARRAY_VERTEX] = selected_verts

	# # Create mesh surface from mesh array.
	# mesh.add_surface_from_arrays(Mesh.PRIMITIVE_POINTS, selected_surface_array)
	# mesh.surface_set_material(mesh.get_surface_count() - 1, graph_material.default_selected_point_material)


"""
-----
	Generate Edges Mesh
	- create vertices, indices
-----
"""		
func _generate_edges_mesh() -> void:
	if points.size() < 2:
		return

	var verts = PackedVector3Array()
	var indices = PackedInt32Array()

	var vert_index = 0
	# add vertices, keep track of their index for edges
	for id in points.keys():
		points[id].vertex_index = vert_index
		verts.append(points[id].position)
		vert_index += 1

	# add edges
	for id in points.keys():
		for connection in points[id].connections:
			indices.append_array([points[id].vertex_index, points[connection].vertex_index])
	
	if indices.size() >= 2:
		var surface_arr = GenerateMeshSurface.generate_surface_array(verts, indices)
		GenerateMeshSurface.append_surface_to_mesh(mesh, surface_arr, Mesh.PRIMITIVE_LINES, graph_material.default_edge_material)

	# # initialize mesh data
	# var surface_array = []
	# surface_array.resize(ArrayMesh.ARRAY_MAX)
	# var verts = PackedVector3Array()
	# var indices = PackedInt32Array()
	

	# var vert_index = 0
	# # add vertices, keep track of their index for edges
	# for id in points.keys():
	# 	points[id].vertex_index = vert_index
	# 	verts.append(points[id].position)
	# 	vert_index += 1

	# # add edges
	# for id in points.keys():
	# 	for connection in points[id].connections:
	# 		indices.append_array([points[id].vertex_index, points[connection].vertex_index])
			

	# # Assign arrays to surface array.
	# surface_array[Mesh.ARRAY_VERTEX] = verts
	# if indices.size() >= 2:
	# 	surface_array[Mesh.ARRAY_INDEX] = indices
	# 	# get surface material
	# 	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_LINES, surface_array)
	# 	mesh.surface_set_material(mesh.get_surface_count() - 1, graph_material.default_edge_material)


"""
-----
	Generate Edges Mesh
	- create vertices, indices
-----
"""	
func _clear_mesh():
	points.clear()
	mesh = ArrayMesh.new()
	last_id = 0
	selected_point_id = -1

"""
-----
	Handle user inputs
-----
"""
func forwarded_input(current_mode:CURSOR_MODE, intersection_point:Vector3, event, modifier_mode:MODIFIER_MODE) -> bool:	
	if intersection_point:
		var center_cell = intersection_point

		if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			match current_mode:

				# ---------------------------
				# SELECT MODE
				# ---------------------------
				CURSOR_MODE.SELECT_POINTS:
					
					# ---------------------------
					# SELECT + MODIFIER MODE
					# ---------------------------
					match modifier_mode:
						
						MODIFIER_MODE.CTRL:
							if selected_point_id != -1:
								add_point(center_cell)


					select_point(center_cell)

				# ---------------------------
				# ADD MODE
				# ---------------------------
				CURSOR_MODE.ADD_POINTS:
					add_point(center_cell)

				# ---------------------------
				# DELETE MODE
				# ---------------------------
				CURSOR_MODE.DELETE_POINTS:
					delete_point(center_cell)
	return true
