class_name ScreenshotComparer
extends RefCounted

var FUCHSIA_PIXEL = PackedByteArray([255, 0, 255, 255])
var WHITE_PIXEL = PackedByteArray([255, 255, 255, 255])

func compare(original: Image, new_shot: Image, shot_name: String) -> float:
	if not _can_run(original, new_shot):
		return 0.0

	var original_data := original.get_data()
	var new_shot_data := new_shot.get_data()
	var diff_result: DiffResult = _compare_img(original_data, new_shot_data)
	_generate_diff_screenshot(original, diff_result, shot_name)

	var total_pixels: int = original.get_data_size()/4.
	return diff_result.different_pixels / float(total_pixels)

func _can_run(original: Image, new_shot: Image) -> bool:
	if original == null:
		push_error("Error: the base screenshot seems to be missing. Try recreating the base images.")
		return false
	if original.get_width() != new_shot.get_width() or original.get_height() != new_shot.get_height():
		push_error("Error: images are not the same size. Was the game resolution changed? If so, try recreating the base images.")
		return false
	return true

func _compare_img(original: PackedByteArray, new_shot: PackedByteArray) -> DiffResult:
	var diff_result := DiffResult.new(0 , [])

	for i in range(original.size()/4.):
		var j: int = i * 4
		var r: float = original[j+0] - new_shot[j+0]
		var g: float = original[j+1] - new_shot[j+1]
		var b: float = original[j+2] - new_shot[j+2]
		var a: float = original[j+3] - new_shot[j+3]
		var diff: float = abs(r)+abs(g)+abs(b)+abs(a)

		if diff >= 0.1:
			diff_result.different_pixels += 1
			diff_result.diff_image.append_array(FUCHSIA_PIXEL)
		else:
			diff_result.diff_image.append_array(WHITE_PIXEL)

	return diff_result

func _generate_diff_screenshot(original: Image, diff_result: DiffResult, shot_name: String) -> void:
	var diff_screenshot: Image = Image.create_from_data(
			original.get_width(), original.get_height(),
			false, original.get_format(), diff_result.diff_image
		)
	diff_screenshot.save_png(ScreenshotConfig.DIFF_SCREENSHOTS_FOLDER + shot_name + ".png")
