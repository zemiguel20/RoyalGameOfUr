extends Node
# Global event bus


## Start of game, after initialization.
signal game_started
## Emited at the start of a new turn. Has the current player.
signal new_turn_started(player: General.Player)
## Emited after dice finished rolling, and has the total value and the player that rolled.
signal rolled(player: General.Player, value: int)

signal move_executed(move: GameMove)
signal game_ended(winner: General.Player)
signal no_moves

signal play_pressed
signal init_board
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
