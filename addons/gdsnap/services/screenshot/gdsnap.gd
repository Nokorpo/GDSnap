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


## Updates the base screenshot for the given screenshot name parameter.
static func update_base_screenshot(shot_name: String, viewport: Viewport) -> void:
	UpdateBaseShotUseCase.new(viewport).run(shot_name)

## Takes a screenshot and compares it with the given screenshot name. [br]
## Returns a ComparisonResult object with the comparison data, such as how different
## from the original it is.
static func take_screenshot(shot_name: String, viewport: Viewport) -> ComparisonResult:
	# TODO better error message when the image doesn't exist
	return CompareScreenshotUseCase.new(viewport).run(shot_name)
