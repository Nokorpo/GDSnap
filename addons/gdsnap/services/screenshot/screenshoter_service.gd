class_name ScreenshoterService
extends RefCounted


func _init() -> void:
	pass

func take_screenshot(shot_name: String, viewport: Viewport) -> Image:
	return viewport.get_texture().get_image()

func update_base_screenshot(shot_name: String, screenshot: Image) -> void:
	var path = ScreenshotConfig.BASE_SCREENSHOTS_FOLDER + shot_name + ".png"
	_store_screenshot(screenshot, path)
	screenshot.save_png(path)

func _store_screenshot(image: Image, path: String) -> void:
	image.save_png(path)

func load_base_screenshot(shot_name: String) -> Image:
	var image := Image.load_from_file(ScreenshotConfig.BASE_SCREENSHOTS_FOLDER + shot_name + ".png")
	if image == null:
		push_error("Error: the base screenshot '%s' seems to be missing. Try recreating the base images." % shot_name)
		printerr("Error: the base screenshot '%s' seems to be missing. Try recreating the base images." % shot_name)
		return null
	return image
