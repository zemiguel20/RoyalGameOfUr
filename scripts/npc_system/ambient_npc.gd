class_name AmbientNPCBase
extends Node3D

@onready var _audio_player = $AudioStreamPlayer3D as AudioStreamPlayer3D

var blackboard: Blackboard

var _animation_player
var _current_tree: BTNode
var _material: BaseMaterial3D
var _npc_manager: NPCSystem
var _has_started = false


func on_ready(manager):
	_npc_manager = manager
	_has_started = true
	_animation_player = get_node(get_meta("animation_player")) as AnimationPlayer
	
	_initialize_blackboard()
	_initialize_tree()
	_current_tree.set_blackboard(blackboard)
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
	

## Virtual method, used to construct a blackboard.
func _initialize_blackboard():
	blackboard = Blackboard.new()
	blackboard.append("Base", self)
	blackboard.append("Audio Player", _audio_player)
	blackboard.append("Animation Player", _animation_player)


## Virtual method, used to construct a behaviour tree and set the [param _current_tree] parameter
func _initialize_tree():
	pass
