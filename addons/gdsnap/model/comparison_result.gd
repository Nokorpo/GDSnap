class_name ComparisonResult
extends RefCounted

static var ERROR: ComparisonResult = ComparisonResult.new(-1, -1, null)

var difference_by_percent: float = 0
var different_pixels: int = 0
var diff_image: Image = null

func _init(_difference_by_percent: float, _different_pixels: int, _diff_image: Image):
	difference_by_percent = _difference_by_percent
	different_pixels = _different_pixels
	diff_image = _diff_image
