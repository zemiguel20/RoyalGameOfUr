class_name AmbientNPCBase
extends PhysicsBody3D

@onready var _mesh = $Capsule_MeshInstance3D as MeshInstance3D
var blackboard: Blackboard

var _current_tree: BTNode
var _material: BaseMaterial3D
var _npc_manager
var _has_started = false


func on_ready(manager):
	_npc_manager = manager
	_has_started = true
	
	_material = _mesh.material_override.duplicate()
	_mesh.material_override = _material
	
	_initialize_blackboard()
	_initialize_tree()
	_current_tree.set_blackboard(blackboard)

	await Engine.get_main_loop().process_frame
	_current_tree.on_start()
	
	
func _process(delta):
	if not _has_started:
		return	
	
	var status = _current_tree.on_process(delta)
	# Reset tree if it is done
	if status != BTNode.Status.Running:
		_current_tree.on_end()
		_current_tree.on_start()
		

## If we ever want to change the behaviour tree an npc is currently using, we could set the tree.	
func set_tree(tree: BTNode):
	_current_tree = tree
	

func _initialize_blackboard():
	blackboard = Blackboard.new()
	blackboard.append("Base", self)


func _initialize_tree():
	pass


# Helper method for showing different actions
func set_material_color(color: Color):
	(_mesh.material_override as BaseMaterial3D).albedo_color = color
	
