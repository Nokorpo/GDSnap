class_name ScreenshotTest
extends Node
## This script shows an example of how to use the built-in ScreenshotTest node
## to run a screenshot test on your game.

signal test_begin(test: ScreenshotTest)
signal test_end(test: ScreenshotTest, result: ComparisonResult)

@export var test_name: String = "default_screenshot_test"
@export var update_base_shot: bool = false

var _timeout_timer: Timer

func _ready() -> void:
	test_begin.connect(GDSnap.on_test_begin)
	test_end.connect(GDSnap.on_test_end)
	test_begin.emit(self)
	_timeout_timer = Timer.new()
	_timeout_timer.one_shot = true
	add_child(_timeout_timer)
	_timeout_timer.timeout.connect(_exit.bind(ComparisonResult.TIMEOUT))
	_timeout_timer.start(ScreenshotConfig.instance.timeout)

	await RenderingServer.frame_post_draw

	print("GDSnap: %s: Starting test." % test_name)
	if update_base_shot:
		print("GDSnap: %s: This run will generate the new base screenshots, so it won't generate results." % test_name)
		var update_use_case := UpdateBaseShotUseCase.new(get_viewport())
		update_use_case.run(test_name)
		_exit(ComparisonResult.UPDATED)
		return

	var compare_use_case := CompareScreenshotUseCase.new(get_viewport())
	var result := compare_use_case.run(test_name)
	if result.difference_by_percent >= ScreenshotConfig.instance.failure_threshold: 
		print("GDSnap: %s: Test failed. The screenshot is %3.2f%% different." % [test_name, (result.difference_by_percent * 100)])
	else:
		print("GDSnap: %s: Test successful." % test_name)

	_exit(result)

func _exit(result: ComparisonResult) -> void:
	test_end.emit(self, result)
