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

## Emited when moving interactively, after player selects pieces to drag.
signal drag_move_start
## Emited when moving interactively, after player cancels piece selection/drag.
signal drag_move_stopped

## Emited when the ai move picker selects a move.
signal npc_selected_move(move: GameMove)
## Emited when the player hovers over a spot with movable pieces.
signal move_hovered(move: GameMove)

## Emited when the opponent starts doing the introduction animation and dialogue sequence.
signal intro_sequence_started
## Emited when the opponent seats down during the intro sequence.
signal opponent_seated
## Emited when the opponent finishes the intro sequence.
signal intro_sequence_finished
## Emited when the opponent is ready to play.
signal opponent_ready
## Emited when the opponent starts thinking before selecting a move.
signal opponent_thinking

## Emited when either player shakes the dice in the first turn.
signal first_turn_dice_shake


## Emited when the opponent starts doing something that halts other actions.
signal opponent_action_prevented
## Emited when the opponent stops doing the thing, and other actions can resume.
signal opponent_action_resumed

signal subtitle_panel_clicked
