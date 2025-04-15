class_name CompareScreenshotUseCase
extends RefCounted

var screenshoter_service: ScreenshoterService
var screenshot_comparison_service: ScreenshotComparisonService
var viewport: Viewport

func _init(_viewport: Viewport) -> void:
	screenshoter_service = GDSnap.instance.screenshoter_service
	screenshot_comparison_service = GDSnap.instance.screenshoter_comparison_service
	viewport = _viewport

func run(shot_name: String) -> ComparisonResult:
	var base_shot := screenshoter_service.load_base_screenshot(shot_name)
	var new_shot := screenshoter_service.take_screenshot(shot_name, viewport)
	var result := screenshot_comparison_service.compare(base_shot, new_shot, shot_name)
	if result != ComparisonResult.ERROR:
		var diff_path := ScreenshotConfig.DIFF_SCREENSHOTS_FOLDER + shot_name + ".png"
		screenshoter_service._store_screenshot(result.diff_image, diff_path)
	return result
