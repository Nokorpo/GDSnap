extends Node

const TEST_NAME: String = "test"

var update_base_shot: bool = false

func _ready() -> void:
	await RenderingServer.frame_post_draw

	print("Starting screenshot test framework.")
	if update_base_shot:
		print("This run will generate the new base screenshots, so it won't generate results.")
		var screenshot := take_screenshot()
		update_base_screenshot(TEST_NAME, screenshot)
		_exit_gracefully()

	var screenshot := take_screenshot()
	var base_shot := load_base_screenshot(TEST_NAME)

	var singlethread_comparer: ScreenshotComparer = ScreenshotComparer.new()
	var result: float = singlethread_comparer.compare(base_shot, screenshot, "single_"+TEST_NAME)
	var multithread_comparer: ScreenshotComparer = MultithreadScreenshotComparer.new(8)
	multithread_comparer.compare(base_shot, screenshot, "multi_"+TEST_NAME)
	#print("result difference=%3.2f%%" % (result * 100))

	_exit_gracefully()

func _exit_gracefully() -> void:
	await get_tree().create_timer(.2).timeout
	# TODO create a singleton runner that records how many screenshots are taken
	# and how many are different from their base screenshots (num errors)
	print("Execution finished! Found no/X failing tests.")
	get_tree().quit()

# FRAMEWORK/RUN LOGIC
func take_screenshot() -> Image:
	return get_viewport().get_texture().get_image()

func update_base_screenshot(shot_name: String, screenshot: Image) -> void:
	var path = ScreenshotConfig.BASE_SCREENSHOTS_FOLDER + shot_name + ".png"
	screenshot.save_png(path)

func load_base_screenshot(shot_name: String) -> Image:
	return Image.load_from_file(ScreenshotConfig.BASE_SCREENSHOTS_FOLDER + shot_name + ".png")
