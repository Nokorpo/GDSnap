extends Node

const TEST_NAME: String = "test"

func _ready() -> void:
	await RenderingServer.frame_post_draw
	init_folders()
	
	var screenshot := take_screenshot()
	#update_base_screenshot(TEST_NAME, screenshot)
	var base_shot := load_base_screenshot(TEST_NAME)
	var start_time = Time.get_unix_time_from_system()
	print(compare_screenshots(base_shot, screenshot, TEST_NAME, 8))
	#print(check_image_single_thread(base_shot, screenshot, TEST_NAME))
	print(Time.get_unix_time_from_system() - start_time)

# INIT
const SCREENSHOTS_FOLDER: String = "res://screenshots/"
const BASE_SCREENSHOTS_FOLDER: String = SCREENSHOTS_FOLDER + "base/"
const DIFF_SCREENSHOTS_FOLDER: String = SCREENSHOTS_FOLDER + "diff/"
func init_folders():
	if not DirAccess.dir_exists_absolute(SCREENSHOTS_FOLDER):
		DirAccess.make_dir_absolute(SCREENSHOTS_FOLDER)
	if not DirAccess.dir_exists_absolute(BASE_SCREENSHOTS_FOLDER):
		DirAccess.make_dir_absolute(BASE_SCREENSHOTS_FOLDER)
	if not DirAccess.dir_exists_absolute(DIFF_SCREENSHOTS_FOLDER):
		DirAccess.make_dir_absolute(DIFF_SCREENSHOTS_FOLDER)
	if not FileAccess.file_exists(SCREENSHOTS_FOLDER + ".gdignore"):
		var file = FileAccess.open(SCREENSHOTS_FOLDER + ".gdignore", FileAccess.WRITE)
		file.close()
	if not FileAccess.file_exists(SCREENSHOTS_FOLDER + ".gitignore"):
		var file = FileAccess.open(SCREENSHOTS_FOLDER + ".gitignore", FileAccess.WRITE)
		file.store_line("diff/")
		file.close()

# FRAMEWORK/RUN LOGIC
func take_screenshot() -> Image:
	return get_viewport().get_texture().get_image()

func update_base_screenshot(shot_name: String, screenshot: Image) -> void:
	var path = BASE_SCREENSHOTS_FOLDER + shot_name + ".png"
	screenshot.save_png(path)

func load_base_screenshot(shot_name: String) -> Image:
	return Image.load_from_file(BASE_SCREENSHOTS_FOLDER + shot_name + ".png")


# SINGLE_THREAD

func check_image_single_thread(original: Image, new_shot: Image, shot_name: String) -> float:
	var diff_image := PackedByteArray()
	
	var original_data := original.get_data()
	var new_shot_data := new_shot.get_data()
	var total_pixels: int = original.get_data_size()/4.
	var different_pixels: int = 0

	# TODO map-reduce w/ threads
	for i in range(original.get_data_size()/4.):
		var j: int = i * 4
		var r: float = original_data[j+0] - new_shot_data[j+0]
		var g: float = original_data[j+1] - new_shot_data[j+1]
		var b: float = original_data[j+2] - new_shot_data[j+2]
		var a: float = original_data[j+3] - new_shot_data[j+3]
		var diff: float = abs(r)+abs(g)+abs(b)+abs(a)
		
		diff_image.append(255) #r
		if diff >= 0.1:
			different_pixels += 1
			diff_image.append(0) #g
		else:
			diff_image.append(255) #g
		diff_image.append(255) #b
		diff_image.append(255) #a

	Image.create_from_data(original.get_width(), original.get_height(),
		false, original.get_format(), diff_image).save_png("res://screenshots/diff/"+shot_name+".png")
	return different_pixels / float(total_pixels)



# PARALLEL



# IMAGE COMPARISON
## Returns difference as %
func compare_screenshots(original: Image, new_shot: Image, shot_name: String, shards: int) -> float:
	if original.get_width() != new_shot.get_width() or original.get_height() != new_shot.get_height():
		push_error("Error: images are not the same size. Was the game resolution changed? Try recreating the base images.")
		return 0.0
	
	var original_shards: Array = split_image(original, shards)
	var new_shot_shards: Array = split_image(new_shot, shards)
	
	var results: Array = parallel_map(original_shards, check_image, [original_shards, new_shot_shards])
	var result := DiffResult.new()
	
	for r: DiffResult in results:
		result.different_pixels += r.different_pixels
		result.diff_image.append_array(r.diff_image)
	
	Image.create_from_data(original.get_width(), original.get_height(),
		false, original.get_format(), result.diff_image).save_png("res://screenshots/diff/"+shot_name+".png")
	var total_pixels: int = original.get_data_size()/4.
	return result.different_pixels / float(total_pixels)

class DiffResult:
	var different_pixels: int = 0
	var diff_image: PackedByteArray = PackedByteArray()

func check_image(original_data: PackedByteArray, new_shot_data: PackedByteArray):
	var diff_result := DiffResult.new()
	for i in range(original_data.size()/4.):
		var j: int = i * 4
		var r: float = original_data[j+0] - new_shot_data[j+0]
		var g: float = original_data[j+1] - new_shot_data[j+1]
		var b: float = original_data[j+2] - new_shot_data[j+2]
		var a: float = original_data[j+3] - new_shot_data[j+3]
		var diff: float = abs(r)+abs(g)+abs(b)+abs(a)
		
		diff_result.diff_image.append(255) #r
		if diff >= 0.1:
			diff_result.different_pixels += 1
			diff_result.diff_image.append(0) #g
		else:
			diff_result.diff_image.append(255) #g
		diff_result.diff_image.append(255) #b
		diff_result.diff_image.append(255) #a
		
	return diff_result


# PARALELLIZATION
func split_image(image: Image, shard_amount: int) -> Array:
	var shard_size: int = image.get_data_size() / shard_amount
	var shards: Array = []
	for i in range(shard_amount):
		shards.append(image.get_data().slice(i * shard_size, (i + 1) * shard_size))
	return shards

func parallel_map(array: Array, callable: Callable, arguments: Array) -> Array:
	var threads: Array[Thread] = []
	for i in range(array.size()):
		var thread = Thread.new()
		var slice_callable: Callable = callable
		for argument in arguments:
			slice_callable = slice_callable.bind(argument[i])
		thread.start(slice_callable)
		threads.append(thread)
	
	var results: Array = []
	for thread in threads:
		var test = thread.wait_to_finish()
		results.append(test)
	
	return results
