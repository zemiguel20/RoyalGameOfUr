class_name VideoResolution


var res: Vector2i = Vector2i(1280, 720)
var aspect_ratio: StringName = "16:9"


static func create(width: int, height: int, ratio: StringName) -> VideoResolution:
	var resolution = VideoResolution.new()
	resolution.res = Vector2i(width, height)
	resolution.aspect_ratio = ratio
	return resolution


static func get_ordered_list() -> Array[VideoResolution]:
	var list: Array[VideoResolution] = [
		VideoResolution.create(1280, 720, "16:9"),
		VideoResolution.create(1280, 800, "16:10"),
		VideoResolution.create(1366, 768, "16:9"),
		VideoResolution.create(1600, 900, "16:9"),
		VideoResolution.create(1920, 1080, "16:9"),
		VideoResolution.create(1920, 1200, "16:10"),
		VideoResolution.create(2560, 1440, "16:9"),
		VideoResolution.create(2560, 1600, "16:10"),
		VideoResolution.create(3840, 2160, "16:9"),
	]
	return list


func _to_string() -> String:
	return "%d x %d (%s)" % [res.x, res.y, aspect_ratio]
