class_name Die extends RigidBody3D
## Entity that represents a rollable binary die. Uses physics for rolling.


signal roll_finished(value: int)

@export var roll_rotation_speed: float = 1.0
@export var min_roll_time: float = 0.7
@export var correction_impulse_strength: float = 3

var highlight: MaterialHighlight
var move_anim: MoveAnimation
var input: SelectionInputReader
var model: MeshInstance3D
var normals: Array[Node3D] = [] ## Normals for each face/tip
var roll_sfx: AudioStreamPlayer3D
var roll_timer: Timer

var rolling: bool = false
var value: int = 0


func _ready():
	highlight = get_node(get_meta("highlight")) as MaterialHighlight
	move_anim = get_node(get_meta("move_animation")) as MoveAnimation
	input = get_node(get_meta("input_reader")) as SelectionInputReader
	model = get_node(get_meta("model")) as MeshInstance3D
	normals.assign(get_node(get_meta("normals_root_node")).get_children())
	roll_sfx = get_node(get_meta("roll_sfx")) as AudioStreamPlayer3D
	roll_timer = get_node(get_meta("timer")) as Timer
	roll_timer.timeout.connect(_force_movement_stop)
	
	freeze = true


## Makes the die start rolling by applying an [param impulse].
## Optionally, the die can be repositioned by giving a [param start_position]
## and a [param start_rotation].
func roll(impulse: Vector3, start_position := global_position, start_rotation := rotation) -> void:
	freeze = false
	linear_velocity = Vector3.ZERO
	angular_velocity = Vector3.ZERO
	
	global_position = start_position
	rotation = start_rotation
	
	var offset = Vector3(0.0, roll_rotation_speed, 0.0)
	apply_impulse(impulse, offset)
	
	rolling = true
	
	# Wait for physics wakeup
	if sleeping:
		await sleeping_state_changed
	
	roll_timer.start()
	roll_sfx.play()
	
	## Extra security measure ensuring that dice do not stop rolling immediately.
	await get_tree().create_timer(min_roll_time).timeout
	if sleeping:
		_on_movement_stopped()
	else:	
		sleeping_state_changed.connect(_on_movement_stopped)
	

func _on_movement_stopped() -> void:
	freeze = true
	rolling = false
	roll_sfx.stop()
	roll_timer.stop()
	
	if sleeping_state_changed.is_connected(_on_movement_stopped):
		sleeping_state_changed.disconnect(_on_movement_stopped)
	
	value = await _read_roll_value(false)
	roll_finished.emit(value)


func _force_movement_stop() -> void:
	if rolling:
		_on_movement_stopped()


func _read_roll_value(is_second_check) -> int:
	# Check which normal is closest (smallest angle) to the UP vector.
	var closest_normal = normals.front() as Node3D
	var smallest_angle = closest_normal.global_basis.y.angle_to(Vector3.UP)
	for normal: Node3D in normals.slice(1):
		var angle = normal.global_basis.y.angle_to(Vector3.UP)
		if angle < smallest_angle:
			closest_normal = normal
			smallest_angle = angle
			
	if not is_second_check and smallest_angle > 0.1 * PI:
		print("Correction!")
		return await _apply_dice_correction(closest_normal, smallest_angle)
	
	var value = closest_normal.get_meta("value") as int
	return value


func _apply_dice_correction(closest_normal, smallest_angle):
	## Apply a correction impulse that scales with the smallest angle
	var correction_impulse = -closest_normal.global_basis.y * smallest_angle * correction_impulse_strength
	apply_impulse(correction_impulse, closest_normal.position)
	await get_tree().create_timer(0.5).timeout
	return await _read_roll_value(true)
