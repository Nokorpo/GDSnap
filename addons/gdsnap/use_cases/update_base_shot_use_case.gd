class_name UpdateBaseShotUseCase
extends RefCounted

var screenshoter_service: ScreenshoterService
var viewport: Viewport

func _init(_viewport: Viewport) -> void:
	screenshoter_service = GDSnap.instance.screenshoter_service
	viewport = _viewport

func run(shot_name: String) -> void:
	var shot := screenshoter_service.take_screenshot(shot_name, viewport)
	screenshoter_service.update_base_screenshot(shot_name, shot)
