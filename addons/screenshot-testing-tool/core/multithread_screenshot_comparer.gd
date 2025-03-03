class_name MultithreadScreenshotComparer
extends ScreenshotComparer

var shard_amount: int

func _init(shards: int = 8) -> void:
	shard_amount = shards

func compare(original: Image, new_shot: Image, shot_name: String) -> float:
	if not _can_run(original, new_shot):
		push_error("Error: images are not the same size. Was the game resolution changed? If so, try recreating the base images.")
		return 0.0
	return await _multithread_compare(original, new_shot, shot_name, shard_amount)

func _multithread_compare(original: Image, new_shot: Image, shot_name: String, shard_amount: int) -> float:
	var shards: Array[DiffParams] = _array_zip(
		_split_image_into_shards(original, shard_amount),
		_split_image_into_shards(new_shot, shard_amount)
	)

	var results: Array = _compare_in_parallel(shards)
	var aggregated_result: DiffResult = results.reduce(_aggregate_results)
	_generate_diff_screenshot(original, aggregated_result, shot_name)

	var total_pixels: int = original.get_data_size()/4.
	return aggregated_result.different_pixels / float(total_pixels)

func _split_image_into_shards(image: Image, shard_amount: int) -> Array[PackedByteArray]:
	var shard_size: int = image.get_data_size() / shard_amount
	var shards: Array[PackedByteArray] = []
	for i in range(shard_amount):
		shards.append(image.get_data().slice(i * shard_size, (i + 1) * shard_size))
	return shards

func _array_zip(original: Array[PackedByteArray], new_shot: Array[PackedByteArray]) -> Array[DiffParams]:
	var result: Array[DiffParams] = []
	for i in range(original.size()):
		result.append(DiffParams.new(original[i], new_shot[i]))
	return result

# array: values iterated and called
# callable: function called
# arguments: arguments supplied to all shards. Added to the end
func _compare_in_parallel(array: Array[DiffParams]) -> Array[DiffResult]:
	var threads: Array[Thread] = []
	for item: DiffParams in array:
		var thread = Thread.new()
		var slice_callable: Callable = _compare_img.bind(item.original, item.new_shot)
		thread.start(slice_callable)
		threads.append(thread)

	var results: Array[DiffResult] = []
	for thread in threads:
		var test = thread.wait_to_finish()
		results.append(test)

	return results

func _aggregate_results(accum: DiffResult, next_item: DiffResult):
	accum.different_pixels += next_item.different_pixels
	accum.diff_image.append_array(next_item.diff_image)
	return accum
