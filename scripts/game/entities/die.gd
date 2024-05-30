class_name Die extends RigidBody3D
## Entity that represents a rollable binary die. Uses physics for rolling.


signal roll_finished(value: int)

var highlight: MaterialHighlight
var move_anim: MoveAnimation
var normals: Array[Node3D] = [] ## Normals for each face/tip


func _ready():
	highlight = get_node(get_meta("highlight")) as MaterialHighlight
	move_anim = get_node(get_meta("move_animation")) as MoveAnimation
	normals.assign(get_node(get_meta("normals_root_node")).get_children())


## Makes the die start rolling by applying an [param impulse].
## Optionally, the die can be repositioned by giving a [param start_position]
## and a [param start_rotation].
func roll(impulse: Vector3, start_position := global_position, start_rotation := rotation) -> void:
	linear_velocity = Vector3.ZERO
	angular_velocity = Vector3.ZERO
	
	global_position = start_position
	rotation = start_rotation
	
	var offset = Vector3(0.0, 0.005, 0.0)
	apply_impulse(impulse, offset)
	
	# Wait for physics wakeup
	if sleeping:
		await sleeping_state_changed
	
	sleeping_state_changed.connect(_on_movement_stopped)


func _on_movement_stopped():
	if not sleeping:
		return
	
	sleeping_state_changed.disconnect(_on_movement_stopped)
	
	var roll_value = _read_roll_value()
	roll_finished.emit(roll_value)


func _read_roll_value() -> int:
	# Check which normal is closest (smallest angle) to the UP vector.
	var closest_normal = normals.front() as Node3D
	var smallest_angle = closest_normal.basis.y.angle_to(Vector3.UP)
	for normal: Node3D in normals.slice(1):
		var angle = normal.basis.y.angle_to(Vector3.UP)
		if angle < smallest_angle:
			closest_normal = normal
			smallest_angle = angle
	
	var value = closest_normal.get_meta("value") as int
	return value
