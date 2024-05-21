@tool
class_name ScrollingTexturePath3D
extends Path3D
## Spawns and scrolls a pool of sprites along the path.


#region Texture editor variables
@export_group("Texture")
@export var texture : Texture2D:
	set(new_value):
		texture = new_value
		_update_sprites()

@export var sprite_scale : Vector3 = Vector3.ONE:
	set(new_value):
		sprite_scale = new_value
		_update_sprites()

@export var flip_v : bool = false:
	set(new_value):
		flip_v = new_value
		_update_sprites()

@export var flip_h : bool = false:
	set(new_value):
		flip_h = new_value
		_update_sprites()

@export_range(0.0, 1.0, 0.01) var alpha : float = 1.0:
	set(new_value):
		alpha = new_value
		_update_sprites()

@export var sorting_offset : float = 1.0:
	set(new_value):
		sorting_offset = new_value
		_update_sprites()
#endregion

#region Scrolling behaviour editor variables
@export_group("Scrolling")
@export_range(1.0, 1000.0) var density : float = 1.0:
	set(new_value):
		density = new_value
		_populate_path()

@export var velocity : float = 1.0
#endregion

var _spawn_pool : Array[PathFollow3D] = []


# Called when the node enters the scene tree for the first time.
func _ready():
	curve_changed.connect(_populate_path)
	_populate_path()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# Scroll objects
	for spawn in _spawn_pool:
		spawn.progress += (velocity * delta)


func _populate_path():
	# Calculate new number of spawns
	var length = curve.get_baked_length()
	var spawn_count = int(length * density)
	
	# Add or remove spawns so that the new spawn count is met
	var difference = spawn_count - _spawn_pool.size()
	if difference > 0:
		_spawn_objects(difference)
	elif difference < 0:
		_despawn_objects(absi(difference))
	
	# Adjust spawn positions
	for i in _spawn_pool.size():
		var spawn = _spawn_pool[i]
		spawn.progress = (length / spawn_count) * i # Spread arrows evenly spaced along path
	
	_update_sprites()


func _spawn_objects(count : int):
	for i in count:
		var spawn = PathFollow3D.new()
		var sprite = Sprite3D.new()
		sprite.axis = Vector3.AXIS_Y
		spawn.add_child(sprite)
		add_child(spawn)
		_spawn_pool.append(spawn)


func _despawn_objects(count : int):
	for i in count:
		var spawn = _spawn_pool.pop_back()
		spawn.queue_free()


func _update_sprites():
	for spawn in _spawn_pool:
		var sprite = spawn.get_child(0) as Sprite3D
		sprite.texture = texture
		sprite.flip_v = flip_v
		sprite.flip_h = flip_h
		sprite.modulate.a = alpha
		sprite.scale = sprite_scale
		sprite.sorting_offset = sorting_offset
