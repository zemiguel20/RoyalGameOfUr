extends Node3D

@export var defaultTimeInSeconds : float; 

var currentDelta = 0;

func _process(delta):
	currentDelta = delta
	
func MoveToTargetPosition(targetPos : Vector3):
	MoveToTargetPositionInSeconds(targetPos, defaultTimeInSeconds)

func MoveToTargetPositionInSeconds(targetPos : Vector3, timeInSeconds : float):
	var oldPos = self.position;
	var distance = oldPos.distance_to(targetPos);
	var moveSpeed = distance / timeInSeconds;
	var t = 0;
	
	while (t < timeInSeconds):
		self.position = self.position.move_toward(targetPos, moveSpeed * currentDelta);
		t += currentDelta;
		# Wait one frame
		await Engine.get_main_loop().process_frame
		
	position = targetPos;
