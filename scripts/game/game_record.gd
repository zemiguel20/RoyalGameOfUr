class_name GameRecord


var uuid: String = StringName(UUID.v4())
var game_version: String = ProjectSettings.get_setting("application/config/version")
var ruleset: Ruleset = preload("res://resources/rulesets/ruleset_finkel.tres")
var p1_npc: bool = false
var p2_npc: bool = false
var turn_history: Array[TurnSummary] = []


static func create(game: BoardGame) -> GameRecord:
	var record = GameRecord.new()
	record.ruleset = game.config.ruleset.duplicate(true)
	record.p1_npc = game.config.p1_npc
	record.p2_npc = game.config.p2_npc
	record.turn_history = game.turn_history
	return record


func to_json() -> Dictionary:
	var dict = {
		"uuid" : uuid,
		"game_version" : game_version,
		"ruleset" : ruleset.to_json(),
		"p1_npc" : p1_npc,
		"p2_npc" : p2_npc,
		"turn_history" : turn_history.map(func(turn: TurnSummary): return turn.to_json()),
	}
	
	return dict
