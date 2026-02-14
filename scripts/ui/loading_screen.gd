class_name LoadingScreen
extends CanvasLayer


@onready var _background: TextureRect = $Background


func fade_in() -> void:
	show()
	await _fade_background(1.0)


func fade_out() -> void:
	await _fade_background(0.0)
	hide()


func _fade_background(target_alpha: float) -> void:
	var tween: Tween = create_tween()
	tween.tween_property(_background, "modulate:a", target_alpha, 0.5)
	await tween.finished
