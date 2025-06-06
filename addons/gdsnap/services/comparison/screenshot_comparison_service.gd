class_name ScreenshotComparisonService
extends RefCounted

func compare(original: Image, new_shot: Image, shot_name: String) -> ComparisonResult:
	if not _can_run(original, new_shot):
		return ComparisonResult.ERROR

	var original_data := original.get_data()
	var new_shot_data := new_shot.get_data()
	var diff := _compare_img(original_data, new_shot_data)
	var diff_image := _generate_image(original, diff.data)
	return ComparisonResult.new(diff.difference_by_percent, diff.different_pixels, diff_image)

func _can_run(original: Image, new_shot: Image) -> bool:
	if original == null:
		push_error("Error: the base screenshot seems to be missing. Try recreating the base images.")
		return false
	if original.get_width() != new_shot.get_width() or original.get_height() != new_shot.get_height():
		push_error("Error: images are not the same size. Was the game resolution changed? If so, try recreating the base images.")
		return false
	return true

func _compare_img(original: PackedByteArray, new_shot: PackedByteArray) -> DiffData:
	var diff_result := DiffData.new(0., 0 , [])

	for i in range(original.size()/4.):
		var j: int = i * 4
		var r: float = original[j+0] - new_shot[j+0]
		var g: float = original[j+1] - new_shot[j+1]
		var b: float = original[j+2] - new_shot[j+2]
		var a: float = original[j+3] - new_shot[j+3]
		var diff: float = abs(r)+abs(g)+abs(b)+abs(a)

		if diff >= 0.1:
			diff_result.different_pixels += 1

		diff_result.data.append_array(PackedByteArray([
			new_shot[j+0],
			original[j+1],
			original[j+2],
			original[j+3]
		]))

	var total_pixels: int = original.size()/4.
	diff_result.difference_by_percent = diff_result.different_pixels / float(total_pixels)
	return diff_result

func _generate_image(original: Image, bytes: PackedByteArray) -> Image:
	return Image.create_from_data(
			original.get_width(), original.get_height(),
			false, original.get_format(), bytes
		)
