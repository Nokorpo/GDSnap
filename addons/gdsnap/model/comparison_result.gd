class_name ComparisonResult
extends RefCounted

## Result when the screenshot was updated
static var UPDATED: ComparisonResult = ComparisonResult.new(-200, -200, null)
## Result when there was an error while running the screenshot test, such as the base screenshot file not existing
static var ERROR: ComparisonResult = ComparisonResult.new(-500, -500, null)
## Result when the test runs for more than the timeout defined in ScreenshotConfig
static var TIMEOUT: ComparisonResult = ComparisonResult.new(-408, -408, null)

var difference_by_percent: float = 0
var different_pixels: int = 0
var diff_image: Image = null

func _init(_difference_by_percent: float, _different_pixels: int, _diff_image: Image):
	difference_by_percent = _difference_by_percent
	different_pixels = _different_pixels
	diff_image = _diff_image
