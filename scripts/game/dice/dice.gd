## Dice controller. Controls the dice rolling animation and stores its value.
class_name Dice
extends Node3D

#region Signals
## Emitted when a single die stops, with its value
signal die_stopped(value: int)
## Emitted when all dice finished, with the final value
signal roll_finished(value: int)
## Emitted when the dice have finished their animation of moving to the correct player.
signal dice_ready()
#endregion

#region Export Variables
## The die that will be used in the board game.
@export var _die_scene: PackedScene
## When enabled, Players and AI can hold the dice to shake them, delaying the throw and adding suspense.
@export var _roll_shaking_enabled: bool = false
## If set to true, player 2 will throw the dice from the other side.
@export var _use_multiple_dice_areas: bool = true
@export_group("Transfer Animation")
@export var _anim_duration: float = 0.7
@export var _arc_height: float = 0.05
#endregion

#region Onready Variables
## Sound effect played when the roll starts.
@onready var _roll_sfx: AudioStreamPlayer = $RollSFX
## Looping sound played while the dice are shaking.
@onready var _shake_sfx: AudioStreamPlayer = $ShakeSFX
## Reference point for the randomly generated 
@onready var _throw_spots_container: Node3D = $DiceArea_P1/ThrowingSpots_P1
## Throwing Position for Player 2. This one is only used when 
## [code] _use_multiple_dice_areas = true [/code]
@onready var _throw_spots_container_p2: Node3D = $DiceArea_P2/ThrowingSpots_P2
## Container node of the spawning spots for the dice.
@onready var _spawn_spot_container: Node3D = $DiceArea_P1/SpawnSpots_P1
## Hitbox that makes it easier to click the dice.
@onready var _click_hitbox: Area3D = $DiceArea_P1/ClickHitbox_P1
## Hitbox that makes it easier to click the dice.
@onready var _click_hitbox_p2: Area3D = $DiceArea_P2/ClickHitbox_P2
## 3D Label displaying the outcome of the dice. Contains its own script with special effects.
@onready var _outcome_label: DiceOutcomeLabel = $DiceArea_P1/Label3D_Outcome_P1
## Approximate area that P1's dice can land in
@onready var _dice_area_p1: Node3D = $DiceArea_P1
## Approximate area that P2's dice can land in
@onready var _dice_area_p2: Node3D = $DiceArea_P2
#endregion

#region Regular Variables
## Current rolled value.
var value: int = 0 

## Array containing every die.
var _dice: Array
var _spawn_spots: Array
## Dictionary that maps _throw_spots_container and _throw_spots_container_p2 to a PlayerId.
var _throwing_spots: Dictionary
## The clicking hitbox that will be used for the current roll.
var _current_click_hitbox: Area3D
## The player that is performing the current roll.
## Used to decide which click hitbox to use.
var _current_player = 0
## Boolean indicating if the dice are currently being shaken.
var _is_shaking: bool = false
## Number of dice that have finished their roll.
var _die_finish_count = 0
#endregion

func _ready() -> void:
	_initialize_dice()
	_cache_throwing_spots()
	disable_selection()
	
	
func _input(event: InputEvent) -> void:
	if not _roll_shaking_enabled:
		return
	
	# This function should not be in _on_die_input_event, 
	# since releasing the mouse can be done outside of the click hitboxes.
	if event is InputEventMouseButton and event.is_released():
		on_dice_release()

func on_roll_phase_started(player: General.Player):
	## If the player that needs to throw does not have the dice yet, move to that players side.
	if _use_multiple_dice_areas and _current_player != player:
		await _move_to_opposite_side()
	
	_current_player = player
	_set_click_hitbox()	
	dice_ready.emit()
	enable_selection()


## Enables selection and highlight effects
func enable_selection() -> void:
	_current_click_hitbox.input_ray_pickable = true
	for die in _dice:
		die.highlight()
		

## Disables selection and highlight effects
func disable_selection() -> void:
	_current_click_hitbox.input_ray_pickable = false
	for die in _dice:
		die.dehighlight()


func on_dice_click():
	if _is_shaking:
		return
	
	if _roll_shaking_enabled:
		_start_dice_shake()
	else:
		_roll()
	
	
func on_dice_release():
	if not _is_shaking:
		return

	_is_shaking = false
	_shake_sfx.stop()
	for die in _dice:
		die.visible = true
	_roll()
	
	
## Plays the dice rolling animation and updates the value. Returns the rolled value.
func _roll() -> int:
	disable_selection()
	_roll_sfx.play()
	value = 0
	_die_finish_count = 0
	var throw_spots = _get_random_free_spot(_current_player, _dice.size())
	
	for i in _dice.size():
		var throw_spot = throw_spots[i]
		_dice[i].roll(throw_spot as DiceSpot)
		
	await roll_finished
	
	#for die in _dice:
		#die.outline_if_one()
	return value
	
	
## Spawns the dice in a random position and connects signals
func _initialize_dice() -> void:
	_cache_spawning_spots()
	var num_dice = Settings.num_dice
	var available_spots = _get_available_spawning_spots(num_dice) 
	
	for _i in num_dice:
		var instance = _die_scene.instantiate()
		add_child(instance)
		_dice.append(instance)
		
		instance.roll_finished.connect(_on_die_finished_rolling)
		instance.global_transform.origin = available_spots[_i].global_position
		instance.global_basis = available_spots[_i].global_basis
	
	_current_click_hitbox = _click_hitbox
	_click_hitbox.input_event.connect(_on_die_input_event)
	if _use_multiple_dice_areas:
		_click_hitbox_p2.input_event.connect(_on_die_input_event)

	
func _start_dice_shake():
	_is_shaking = true
	for die in _dice:
		die.visible = false
	_shake_sfx.play()
	
	
func _move_to_opposite_side():
	var other_hitbox = _click_hitbox_p2 if _current_click_hitbox == _click_hitbox else _click_hitbox
	var diff_vector = other_hitbox.global_position - _current_click_hitbox.global_position
	await _anim_move_dice_to_position(diff_vector, _anim_duration)


func _anim_move_dice_to_position(move_vector: Vector3, duration: float):
	# Linear translation of X and Z
	for die in _dice:
		var tween_xz = create_tween()
		tween_xz.bind_node(die).set_parallel(true)
		tween_xz.tween_property(die, "global_position:x", die.global_position.x + move_vector.x, duration)
		tween_xz.tween_property(die, "global_position:z", die.global_position.z + move_vector.z, duration)
	
		print("Move Vector", move_vector.y)
	
		# Arc translation of Y
		var high_point = die.global_position.y + _arc_height * global_basis.get_scale().y
		var tween_y = create_tween().set_trans(Tween.TRANS_CUBIC)
		tween_y.tween_property(die, "global_position:y", high_point, duration/2).set_ease(Tween.EASE_OUT)
		## NOTE Tbh no clue why here I should suddenly do - move_vector instead of plus, but ill take it...
		tween_y.tween_property(die, "global_position:y", die.global_position.y - move_vector.y, duration/2).set_ease(Tween.EASE_IN)
	
	
	# Tweens run at same time, so only wait for one of them
	await get_tree().create_timer(duration).timeout
			

## Returns [param amount] random but different spawning spots.
func _get_available_spawning_spots(amount: int):
	_spawn_spots.shuffle()
	return _spawn_spots.slice(0, amount)
		

## Get all spawning spots corresponding to [param _player]
func _get_throwing_spots(_player: General.Player) -> Array:
	return _throwing_spots[_player]
	
	
## Returns [param amount] random but different throwing spots, corresponding to [param _player].
func _get_random_free_spot(_player: General.Player, amount: int) -> Array:
	var spots = _get_throwing_spots(_player)
	spots.shuffle()
	
	return spots.slice(0, amount)
	
	
func _cache_spawning_spots():
	_spawn_spots = _spawn_spot_container.get_children()
	
	
	
func _cache_throwing_spots():
	var spots_p1 = _throw_spots_container.get_children() as Array[DiceSpot]
	var spots_p2 = _throw_spots_container_p2.get_children() as Array[DiceSpot]
	
	_throwing_spots = {}
	_throwing_spots[General.Player.ONE] = spots_p1
	if _use_multiple_dice_areas:
		_throwing_spots[General.Player.TWO] = spots_p2
	else:
		_throwing_spots[General.Player.TWO] = spots_p1
		

## Determines which click hitbox should be used for starting the next roll.
func _set_click_hitbox():
	if _use_multiple_dice_areas:
		_current_click_hitbox = _click_hitbox if _current_player == General.Player.ONE else _click_hitbox_p2


func _on_die_input_event(_camera, event : InputEvent, _position, _normal, _shape_idx):
	if event is InputEventMouseButton and event.is_pressed() \
	and event.button_index == MOUSE_BUTTON_LEFT:
		on_dice_click()


func _on_die_finished_rolling(die_value: int):
	value += die_value
	_die_finish_count += 1
	die_stopped.emit(die_value)
	if (_dice.size() <= _die_finish_count):
		## TODO Polish: Might be nice to have a delay when throwing a 0
		roll_finished.emit(value)
