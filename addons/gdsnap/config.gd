class_name ScreenshotConfig
extends RefCounted

# TODO allow setting these up from a UI/cli params

const SCREENSHOTS_FOLDER: String = "res://screenshots/"
const BASE_SCREENSHOTS_FOLDER: String = SCREENSHOTS_FOLDER + "base/"
const DIFF_SCREENSHOTS_FOLDER: String = SCREENSHOTS_FOLDER + "diff/"
const RESULT_FILE_PATH: String = SCREENSHOTS_FOLDER + "screenshots.xml"

const shard_amount: int = 8
const run_in_paralell: bool = true

const failure_threshold: float = 0.001
const timeout: float = 3

static var instance: ScreenshotConfig:
	get():
		if instance == null:
			instance = ScreenshotConfig.new()
		return instance
