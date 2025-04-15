class_name ScreenshotConfig
extends RefCounted

# TODO allow setting these up from a UI/cli params

const SCREENSHOTS_FOLDER: String = "res://screenshots/"
const BASE_SCREENSHOTS_FOLDER: String = SCREENSHOTS_FOLDER + "base/"
const DIFF_SCREENSHOTS_FOLDER: String = SCREENSHOTS_FOLDER + "diff/"

const shard_amount: int = 8
const run_in_paralell: bool = true

const regenerate_base_screenshots: bool = false

var INSTANCE: ScreenshotConfig:
	get():
		if INSTANCE == null:
			INSTANCE = ScreenshotConfig.new()
		return INSTANCE
