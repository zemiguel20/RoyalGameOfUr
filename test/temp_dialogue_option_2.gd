extends Label3D

@export var min_font_size: float = 13
@export var max_font_size: float = 40


func _ready():
	_on_option_2_area_exited()


func _on_option_2_area_entered():
	font_size = max_font_size
	print("hoi")
	

func _on_option_2_area_exited():
	font_size = min_font_size
	print("doie")
