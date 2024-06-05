extends Node
# Global event bus


signal game_started
signal roll_phase_started(player: General.Player)
signal rolled(player: General.Player, value: int)
signal move_phase_started(player: General.Player, moves: Array[GameMove])
signal game_ended
signal no_moves
