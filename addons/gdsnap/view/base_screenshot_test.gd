extends Node
## This script shows an example of how to use the built-in ScreenshotTest node
## to run a screenshot test on your game.

@export var test_name: String = "default_screenshot_test"
@export var update_base_shot: bool = true

func _ready() -> void:
	await RenderingServer.frame_post_draw

	print("Starting screenshot test framework.")
	if update_base_shot:
		print("This run will generate the new base screenshots, so it won't generate results.")
		var update_use_case := UpdateBaseShotUseCase.new(get_viewport())
		update_use_case.run(test_name)
		_exit_gracefully()

	var compare_use_case := CompareScreenshotUseCase.new(get_viewport())
	var result := compare_use_case.run(test_name)
	print("The screenshot is %f%% different" % result.difference_by_percent)

	_exit_gracefully()

func _exit_gracefully() -> void:
	await get_tree().create_timer(.2).timeout
	# TODO create a singleton runner that records how many screenshots are taken
	# and how many are different from their base screenshots (num errors)
	print("Execution finished! Found no/X failing tests.")
	get_tree().quit()
