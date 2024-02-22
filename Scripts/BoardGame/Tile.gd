extends Node

@export var material_changer : MaterialChangerUtility

func enable_highlighting():
	material_changer.highlight()

func disable_highlighting():
	material_changer.dehighlight()
