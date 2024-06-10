extends Node
## Node that spawns MovePickers for both players, depending on playing hotseat or not.

@export var move_picker_interactive: PackedScene
@export var move_picker_ai: PackedScene

func _ready():
	GameEvents.play_pressed.connect(_spawn_move_pickers)
	
	
func _spawn_move_pickers():
	## Player 1 is always interactive move picker
	var move_picker_p1 = move_picker_interactive.instantiate()
	## Player 2 can be an AI or second player
	var move_picker_p2: MovePicker
	if Settings.is_hotseat_mode:
		move_picker_p2 = move_picker_interactive.instantiate() as MovePicker
	else:
		move_picker_p2 = move_picker_ai.instantiate() as MovePicker
	
	add_child(move_picker_p1)
	add_child(move_picker_p2)
	move_picker_p2.assigned_player = General.Player.TWO
