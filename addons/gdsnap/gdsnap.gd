@tool
extends EditorPlugin

func _enter_tree() -> void:
	_init_folders()

func _exit_tree() -> void:
	# Clean-up of the plugin goes here.
	pass

func _init_folders():
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
