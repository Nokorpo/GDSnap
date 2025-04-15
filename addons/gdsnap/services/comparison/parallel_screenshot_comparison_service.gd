class_name ParallelScreenshotComparisonService
extends ScreenshotComparisonService

var shard_amount: int

func _init(shards: int = 8) -> void:
	shard_amount = shards

func compare(original: Image, new_shot: Image, shot_name: String) -> ComparisonResult:
	if not _can_run(original, new_shot):
		return null
	return await _multithread_compare(original, new_shot, shot_name, shard_amount)

func _multithread_compare(original: Image, new_shot: Image, shot_name: String, shard_amount: int) -> ComparisonResult:
	var shards: Array[DiffParams] = _array_zip(
		_split_image_into_shards(original, shard_amount),
		_split_image_into_shards(new_shot, shard_amount)
	)

	var results: Array = _compare_in_parallel(shards)
	var aggregated_diff: DiffData = results.reduce(_aggregate_results)
	_generate_image(original, aggregated_diff.data)

	var total_pixels: int = original.get_data_size()/4.
	var percent: float = aggregated_diff.different_pixels / float(total_pixels)
	var diff_image: Image = _generate_image(original, aggregated_diff.data)
	return ComparisonResult.new(percent, aggregated_diff.different_pixels, diff_image)

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
func _compare_in_parallel(array: Array[DiffParams]) -> Array[DiffData]:
	var threads: Array[Thread] = []
	for item: DiffParams in array:
		var thread = Thread.new()
		var slice_callable: Callable = _compare_img.bind(item.original, item.new_shot)
		thread.start(slice_callable)
		threads.append(thread)

	var results: Array[DiffData] = []
	for thread in threads:
		var test = thread.wait_to_finish()
		results.append(test)

	return results

func _aggregate_results(accum: DiffData, next_item: DiffData):
	accum.different_pixels += next_item.different_pixels
	accum.data.append_array(next_item.data)
	return accum
