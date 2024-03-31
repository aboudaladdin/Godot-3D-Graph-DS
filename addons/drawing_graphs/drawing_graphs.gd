@tool
extends EditorPlugin

# ui
var editor_toolbar_menu = null
var is_drawing: bool = false

# modes
enum CURSOR_MODE {SELECT_POINTS, ADD_POINTS, DELETE_POINTS, LINK_POINTS, CUT_EDGES}
var current_mode = CURSOR_MODE.SELECT_POINTS

enum MODIFIER_MODE {NONE, CTRL, SHIFT, ALT}
var modifier_mode = MODIFIER_MODE.NONE
var modifier_cooldown = 500 # 500 milliseconds
var modifier_start_time = 0


# brush
var brush_cursor
var calculated_size:float = 0.05
var invert_brush = false


var process_drawing:bool = false

var editable_object:bool = false
var pointGraphObject

var raycast_hit:bool = false
var hit_position


"""
-----
	Enter/Exit tree
-----
"""	
func _enter_tree():
	editor_toolbar_menu = preload("res://addons/drawing_graphs/ui/toolbar.tscn").instantiate()
	editor_toolbar_menu.hide()
	
	# connect button toggle signal
	editor_toolbar_menu.connect("cursor_mode_changed", cursor_mode_changed)

	add_control_to_container(EditorPlugin.CONTAINER_SPATIAL_EDITOR_MENU, editor_toolbar_menu)
	
	# selection changed signal:
	get_editor_interface().get_selection().connect("selection_changed", self._selection_changed)

	# load brush cursor
	brush_cursor = preload("res://addons/drawing_graphs/res/brush_cursor/BrushCursor.tscn").instantiate()
	brush_cursor.visible = false
	add_child(brush_cursor)

func _exit_tree():
	remove_control_from_container(EditorPlugin.CONTAINER_SPATIAL_EDITOR_MENU, editor_toolbar_menu)

	editor_toolbar_menu.queue_free()	
	brush_cursor.queue_free()



func cursor_mode_changed(mode):
	current_mode = mode
	
"""
-----
	Allow editor to forward us the spatial GUI input for drawing points
-----
"""	
func _selection_changed() -> void:
	editor_toolbar_menu.hide()

	var selection = get_editor_interface().get_selection().get_selected_nodes()
	if selection.size() == 1 and selection[0] is PointGraph3D:
		pointGraphObject = selection[0]
		editor_toolbar_menu.show()
		editable_object = true
		brush_cursor.visible = true

	else:
		editable_object = false
		editor_toolbar_menu.hide()
		pointGraphObject = null
		brush_cursor.visible = false

func _handles(obj) -> bool:
	return editable_object

func _forward_3d_gui_input(camera, event):
	_display_brush()
	_raycast(camera, event)

	if raycast_hit:
		if pointGraphObject != null:
			pointGraphObject.forwarded_input(current_mode, hit_position, event, modifier_mode)

		return int(_user_input(event)) #the returned value blocks or unblocks the default input from godot
	else:
		return 0

func modifier_input(event):

	# handle modifier input

	if modifier_start_time + modifier_cooldown < Time.get_ticks_msec():
		modifier_mode = MODIFIER_MODE.NONE

	if event is InputEventKey and event.keycode == KEY_CTRL:
		if event.is_pressed():
			modifier_mode = MODIFIER_MODE.CTRL
			modifier_start_time = Time.get_ticks_msec()
		elif event.is_released():
			modifier_start_time = 0

	if event is InputEventKey and event.keycode == KEY_SHIFT:
		if event.is_pressed():
			modifier_mode = MODIFIER_MODE.SHIFT
			modifier_start_time = Time.get_ticks_msec()
		elif event.is_released():
			modifier_start_time = 0
			
	if event is InputEventKey and event.keycode == KEY_ALT:
		if event.is_pressed():
			modifier_mode = MODIFIER_MODE.ALT
			modifier_start_time = Time.get_ticks_msec()
		elif event.is_released():
			modifier_start_time = 0

"""
-----
	Raycast find intersections
-----
"""	
func _raycast(viewport_camera:Node, event:InputEvent) -> void:
	if event is InputEventMouse:
		var mousepos = viewport_camera.get_viewport().get_mouse_position()
		var origin = viewport_camera.project_ray_origin(mousepos)
		var intersection_point = null

		if viewport_camera.projection == Camera3D.PROJECTION_PERSPECTIVE:
			var end = origin + viewport_camera.project_ray_normal(mousepos) * viewport_camera.far
			intersection_point = Plane(Vector3(0, 1, 0), 0).intersects_ray(origin,end)

		elif viewport_camera.projection == Camera3D.PROJECTION_ORTHOGONAL:
			origin.y = 0
			intersection_point = origin

		if intersection_point == null:
			raycast_hit = false
			return
		if intersection_point != null:
			raycast_hit = true
			hit_position = intersection_point
			



func _display_brush() -> void:
	if raycast_hit:
		#brush_cursor.visible = true
		brush_cursor.position = hit_position
		brush_cursor.scale = Vector3.ONE * calculated_size
	else:
		brush_cursor.visible = false

	match current_mode:
		CURSOR_MODE.SELECT_POINTS:
			brush_cursor.mesh.surface_get_material(0).albedo_color = Color(0.1, 0.75, 0.2, 0.55)
		CURSOR_MODE.ADD_POINTS:
			brush_cursor.mesh.surface_get_material(0).albedo_color = Color(0.1, 0.2, 0.75, 0.55)
		CURSOR_MODE.DELETE_POINTS:
			brush_cursor.mesh.surface_get_material(0).albedo_color = Color(0.75, 0.1, 0.1, 0.55)

func _user_input(event) -> bool:
	modifier_input(event)

	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.is_pressed():
			process_drawing = true
			return true
		else:
			process_drawing = false
			return false

	if event is InputEventKey and event.keycode == KEY_CTRL:
		if event.is_pressed():
			invert_brush = true
			return false
		else:
			invert_brush = false
			return false
	else:
		return false

	
	