class_name Die
extends RigidBody3D
## Entity that represents a rollable binary die. Uses physics for rolling.


signal clicked
signal hold_started
signal hold_stopped
signal placed ## Emitted by [method place]
signal rolled(value: int)

enum HighlightType {
	NONE,
	NEUTRAL,
	SELECTABLE,
	HOVERED,
	RESULT_POSITIVE,
	RESULT_NEGATIVE,
}

var last_rolled_value: int = 0
var is_rolling: bool = false

# Sound is played once die hits the table
# Starting with 'true' prevents it possibly being played outside of rolling
var _sound_played: bool = true

var _tips: Array[DieTip] = []

# Cached values for _integrate_forces function.
var _roll_requested = false
var _impulse: Vector3
var _throw_position: Vector3

@onready var _animator: SimpleMovementAnimationPlayer = $SimpleMovementAnimationPlayer
@onready var _highlighter: MeshHighlighter = $MeshHighlighter
@onready var _input_reader: SelectionInputReader = $SelectionInputReader
@onready var _roll_force_stop_timer: Timer = $RollForceStopTimer
@onready var _roll_sfx: AudioStreamPlayer3D = $RollSFX


func _ready() -> void:
	_tips.assign($Tips.get_children())
	
	_input_reader.mouse_entered.connect(mouse_entered.emit)
	_input_reader.mouse_exited.connect(mouse_exited.emit)
	_input_reader.clicked.connect(clicked.emit)
	_input_reader.hold_started.connect(hold_started.emit)
	_input_reader.hold_stopped.connect(hold_stopped.emit)
	
	body_entered.connect(_on_collision)


## Coroutine that moves the die to the target point in global space. Emits [signal placed].
func place(point_global: Vector3) -> void:
	_animator.move_arc(point_global, 0.4, 0.1)
	await _animator.movement_finished
	placed.emit()


func set_highlight(type: HighlightType) -> void:
	if type == HighlightType.NONE:
		_highlighter.set_active(false)
		return
	
	_highlighter.set_active(true)
	
	if type == HighlightType.NEUTRAL:
		_highlighter.set_material_color(Color.GHOST_WHITE)
	elif type == HighlightType.SELECTABLE:
		_highlighter.set_material_color(Color.MEDIUM_AQUAMARINE)
	elif type == HighlightType.HOVERED:
		_highlighter.set_material_color(Color.AQUAMARINE)
	elif type == HighlightType.RESULT_POSITIVE:
		_highlighter.set_material_color(Color.GREEN)
	elif type == HighlightType.RESULT_NEGATIVE:
		_highlighter.set_material_color(Color.RED)


func set_input_reading(active: bool) -> void:
	_input_reader.set_input_reading(active)


## Rolls the die from a given point by applying an impulse.
## Emits [signal rolled] when rolling finishes.
func roll(impulse: Vector3, throw_position_global: Vector3) -> void:
	is_rolling = true
	_sound_played = false
	
	# Due to how Rigidbodies work, changing the physics properties and position
	# should be done in the _integrate_forces function.
	# Thus these values are cached for this physics callback to use
	_impulse = impulse
	_throw_position = throw_position_global
	_roll_requested = true
	sleeping = false # awakes body so that _integrate_forces can be called
	
	# Wait until _integrate forces processes the roll request
	while(_roll_requested == true):
		await get_tree().physics_frame
	
	# Wait for physics wakeup, because the next part depends on the sleeping state.
	if sleeping:
		await sleeping_state_changed
	
	_roll_force_stop_timer.start() # Used as fallback
	while(not sleeping and not _roll_force_stop_timer.is_stopped()):
		await get_tree().create_timer(0.1).timeout
	
	last_rolled_value = _read_roll_value()
	rolled.emit(last_rolled_value)
	
	is_rolling = false


# Die throw logic is done here, as it is recommended for Rigidbodies
func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:
	if _roll_requested:
		_roll_requested = false
		
		state.linear_velocity = Vector3.ZERO
		state.angular_velocity = Vector3.ZERO
		
		state.transform.origin = _throw_position
		state.transform.basis = Basis.from_euler(_get_random_rotation())
		
		# Offseting the impulse contact point generates torque
		var roll_speed = 0.005
		var offset = Vector3(0.0, roll_speed, 0.0)
		state.apply_impulse(_impulse * randf_range(0.85, 1.15), offset)


func _get_random_rotation() -> Vector3:
	var angle_x = randf_range(-PI, PI)
	var angle_y = randf_range(-PI, PI)
	var angle_z = randf_range(-PI, PI)
	return Vector3(angle_x, angle_y, angle_z)


func _read_roll_value() -> int:
	# Check which tip is closest to closest to pointing up.
	var chosen_tip: DieTip = _tips[0]
	var smallest_angle = chosen_tip.angle_to_up()
	for tip: DieTip in _tips.slice(1):
		var angle = tip.angle_to_up()
		if angle < smallest_angle:
			chosen_tip = tip
			smallest_angle = angle
	
	return chosen_tip.value


func _on_collision(body: Node):
	if not _sound_played and body.is_in_group("table"):
		_roll_sfx.play()
		_sound_played = true
