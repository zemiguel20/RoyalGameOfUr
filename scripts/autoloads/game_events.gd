extends Node
# Global event bus


## Start of game, after initialization.
signal game_started
## Emited at the start of a new turn.
signal new_turn_started()
## Emited after dice finished rolling, and has the total value.
signal rolled(value: int)
## Emited after the entire sequence of rolling and highlighting the dice is finished.
signal roll_sequence_finished
## Emited when there are no available moves for the current player.
signal no_moves
## Emited after a move finished execution.
signal move_executed(move: GameMove)
## Emited when a player wins and the game ends.
signal game_ended()


## Emited when game start is issued through UI or input
signal play_pressed
## Emited when returning to main menu, by UI or input
signal back_to_main_menu_pressed

## Emited when the camera look around mode is activated
signal camera_look_around_started
## Emited when the camera look around mode is turned off
signal camera_look_around_stopped


signal intro_finished

signal first_turn_dice_shake
signal try_play_tutorial_dialog(category: DialogueSystem.Category)
signal reaction_piece_captured(move: GameMove)
signal rolled_by_player(value: int, player: General.Player)

signal fast_move_toggled(enabled: bool)
signal drag_move_start
signal drag_move_end
signal opponent_thinking

signal opponent_action_prevented
signal opponent_action_resumed

signal subtitle_panel_clicked
