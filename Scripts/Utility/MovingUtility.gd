class_name MovingUtility
extends Node3D

@export var defaultTimeInSeconds : float

var currentDelta = 0;

func _process(delta):
	currentDelta = delta
	
func move_to_target_position(targetPos : Vector3):
	move_to_target_position_in_seconds(targetPos, defaultTimeInSeconds)

func move_to_target_position_in_seconds(targetPos : Vector3, timeInSeconds : float):
	var oldPos = global_position
	var distance = oldPos.distance_to(targetPos)
	var moveSpeed = distance / timeInSeconds
	var t = 0
	
	while (t < timeInSeconds):
		global_position = global_position.move_toward(targetPos, moveSpeed * currentDelta)
		t += currentDelta
		# Wait one frame
		await Engine.get_main_loop().process_frame
		
	position = targetPos

func move_to_target_position_in_seconds_with_arc(targetPos : Vector3, arc_height : float, height_curve : Curve, timeInSeconds : float):
	var oldPos = global_position
	var global_arc_heigth = arc_height + oldPos.y
	var t = 0
	
	while (t < timeInSeconds):
		var progress = t/timeInSeconds
		global_position.x = lerpf(oldPos.x, targetPos.x, progress)
		global_position.z = lerpf(oldPos.z, targetPos.z, progress)
		# Handle the y-axis independentely
		global_position.y = lerpf(oldPos.y, global_arc_heigth, height_curve.sample(progress))
		t += currentDelta
		# Wait one frame
		await Engine.get_main_loop().process_frame
		
	global_position = targetPos
