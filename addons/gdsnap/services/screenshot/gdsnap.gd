class_name GDSnap
extends RefCounted

var screenshoter_service: ScreenshoterService
var screenshoter_comparison_service: ScreenshotComparisonService

static var instance: GDSnap:
	get:
		if instance == null:
			instance = GDSnap.new()
			instance._init_services()
		return instance

func _init_services() -> void:
	screenshoter_service = ScreenshoterService.new()
	if true: #if parallel
		screenshoter_comparison_service = ParallelScreenshotComparisonService.new()
	else:
		screenshoter_comparison_service = ScreenshotComparisonService.new()


static func update_base_screenshot(shot_name: String, viewport: Viewport) -> void:
	UpdateBaseShotUseCase.new(viewport).run(shot_name)

static func take_screenshot(shot_name: String, viewport: Viewport) -> void:
	CompareScreenshotUseCase.new(viewport).run(shot_name)
