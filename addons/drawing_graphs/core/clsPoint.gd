class_name Point extends Resource

@export var id = -1
@export var position = Vector3(0,0,0)
@export var vertex_index = -1
@export var connections = []

# when deleted, this point needs to be removed from other points connections array
@export var connections_from = []