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
