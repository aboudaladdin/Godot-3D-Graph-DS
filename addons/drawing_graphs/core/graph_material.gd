@tool
class_name GraphMaterial extends Resource

@export var default_point_material: StandardMaterial3D
@export var default_selected_point_material: StandardMaterial3D
@export var default_edge_material: StandardMaterial3D

@export var POINT_SIZE: int = 5:
	set(value):
		POINT_SIZE = value
		if default_point_material != null:
			default_point_material.point_size = POINT_SIZE

@export var SELECTED_POINT_SIZE: int = 8:
	set(value):
		SELECTED_POINT_SIZE = value
		if default_selected_point_material != null:
			default_selected_point_material.point_size = SELECTED_POINT_SIZE

@export var reset_to_default: bool:
	set(value):
		reset_to_default = !reset_to_default
		reset_to_default = false
		_reset_to_default()


func _reset_to_default():
	default_edge_material = StandardMaterial3D.new()
	default_edge_material.vertex_color_use_as_albedo = true
	default_edge_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	default_edge_material.albedo_color = Color(0.7, 0.7, 0.8, 1.0)

	default_point_material = default_edge_material.duplicate()
	default_point_material.use_point_size = true
	default_point_material.point_size = POINT_SIZE
	default_point_material.albedo_color = Color(1.0, 1.0, 1.0, 0.9)

	default_selected_point_material = default_point_material.duplicate()
	default_selected_point_material.blend_mode = BaseMaterial3D.BLEND_MODE_ADD
	default_selected_point_material.cull_mode = BaseMaterial3D.CULL_DISABLED
	default_selected_point_material.point_size = SELECTED_POINT_SIZE
	default_selected_point_material.albedo_color = Color(1.0, 0.0, 0.0, 1.0)