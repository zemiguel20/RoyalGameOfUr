extends Node
# Global event bus


signal game_started
signal roll_phase_started(player: General.Player)
signal rolled(value: int)
signal move_phase_started(player: General.Player, rolled_value: int)
signal move_executed(move: GameMove)
signal game_ended
signal no_moves
signal zero_rolled

signal play_pressed
signal intro_finished

signal try_play_tutorial_dialog(category: DialogueSystem.Category)
signal reaction_piece_captured(move: GameMove)
signal rolled_by_player(value: int, player: General.Player)

signal fast_move_toggled(enabled: bool)
signal drag_move_start
signal drag_move_end
