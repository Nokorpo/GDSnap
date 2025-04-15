@tool
extends EditorPlugin

var test_node_script: Script = preload("res://addons/gdsnap/view/base_screenshot_test.gd")
var test_node_icon: Texture2D = preload("res://addons/gdsnap/assets/screenshot_test_node_icon.svg")

var screenshoter_service: ScreenshoterService
var screenshoter_comparison_service: ScreenshotComparisonService

func _enter_tree() -> void:
	_init_folders()
	add_custom_type("ScreenshotTest", "Node", test_node_script, test_node_icon)

func _exit_tree() -> void:
	remove_custom_type("ScreenshotTest")

func _init_folders() -> void:
	if not DirAccess.dir_exists_absolute(ScreenshotConfig.SCREENSHOTS_FOLDER):
		DirAccess.make_dir_absolute(ScreenshotConfig.SCREENSHOTS_FOLDER)
	if not DirAccess.dir_exists_absolute(ScreenshotConfig.BASE_SCREENSHOTS_FOLDER):
		DirAccess.make_dir_absolute(ScreenshotConfig.BASE_SCREENSHOTS_FOLDER)
	if not DirAccess.dir_exists_absolute(ScreenshotConfig.DIFF_SCREENSHOTS_FOLDER):
		DirAccess.make_dir_absolute(ScreenshotConfig.DIFF_SCREENSHOTS_FOLDER)
	if not FileAccess.file_exists(ScreenshotConfig.SCREENSHOTS_FOLDER + ".gdignore"):
		var file = FileAccess.open(ScreenshotConfig.SCREENSHOTS_FOLDER + ".gdignore", FileAccess.WRITE)
		file.close()
	if not FileAccess.file_exists(ScreenshotConfig.SCREENSHOTS_FOLDER + ".gitignore"):
		var file = FileAccess.open(ScreenshotConfig.SCREENSHOTS_FOLDER + ".gitignore", FileAccess.WRITE)
		file.store_line("diff/")
		file.close()
