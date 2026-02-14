@tool
class_name ScrollingTexturePath3D
extends Path3D
## Spawns and scrolls a pool of sprites along the path.


@export_group("Texture")

## Texture of the sprites to scroll
@export var texture: Texture2D:
	set(new_value):
		texture = new_value
		_dirty = true

## Scale of the sprite
@export var sprite_scale: Vector3 = Vector3.ONE:
	set(new_value):
		sprite_scale = new_value
		_dirty = true

## Flip the sprites vertically
@export var flip_v: bool = false:
	set(new_value):
		flip_v = new_value
		_dirty = true

## Flip the sprites horizontally
@export var flip_h: bool = false:
	set(new_value):
		flip_h = new_value
		_dirty = true

## Transparency of the sprites
@export_range(0.0, 1.0, 0.01) var alpha: float = 1.0:
	set(new_value):
		alpha = new_value
		_dirty = true

## Adjust this in case of clipping
@export var sorting_offset: float = 1.0:
	set(new_value):
		sorting_offset = new_value
		_dirty = true

## Modulates the color of the sprites
@export var color_modulate := Color.WHITE:
	set(new_value):
		color_modulate = new_value
		_dirty = true

@export_group("Scrolling")

## Number of sprites per meter.
@export var density : float = 1.0:
	set(new_value):
		density = maxf(new_value, 0.0) # Density cannot go below 0
		_dirty = true

## m/s
@export var velocity : float = 1.0

var _dirty: bool = false # Flag to update visuals
var _spawns: Array[PathFollow3D] = []


# Called when the node enters the scene tree for the first time.
func _ready():
	curve_changed.connect(func(): _dirty = true)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# Scroll objects
	if _dirty:
		_dirty = false
		_refresh_path()
	for spawn: PathFollow3D in _spawns:
		spawn.progress += (velocity * delta)


func _refresh_path():
	# Calculate new number of spawns
	var length = curve.get_baked_length()
	var spawn_count = int(length * density)
	var step = length / spawn_count
	
	# Add or remove spawns so that the new spawn count is met
	var difference = spawn_count - _spawns.size()
	if difference > 0:
		_spawn_objects(difference)
	elif difference < 0:
		_despawn_objects(absi(difference))
	
	if difference != 0:
		# Adjust spawn positions
		for i in _spawns.size():
			_spawns[i].progress = i * step # Spread sprites evenly spaced along path
	
	_update_sprites()


func _spawn_objects(count: int):
	for i in count:
		var spawn = PathFollow3D.new()
		var sprite = Sprite3D.new()
		sprite.axis = Vector3.AXIS_Y
		spawn.add_child(sprite)
		add_child(spawn)
		_spawns.append(spawn)


func _despawn_objects(count: int):
	for i in count:
		var spawn = _spawns.pop_back() as PathFollow3D
		spawn.queue_free()


func _update_sprites():
	for spawn in _spawns:
		var sprite = spawn.get_child(0) as Sprite3D
		sprite.texture = texture
		sprite.flip_v = flip_v
		sprite.flip_h = flip_h
		sprite.modulate = color_modulate
		sprite.modulate.a = alpha
		sprite.scale = sprite_scale
		sprite.sorting_offset = sorting_offset
