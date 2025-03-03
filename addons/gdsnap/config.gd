class_name ScreenshotConfig
extends Node

const SCREENSHOTS_FOLDER: String = "res://screenshots/"
const BASE_SCREENSHOTS_FOLDER: String = SCREENSHOTS_FOLDER + "base/"
const DIFF_SCREENSHOTS_FOLDER: String = SCREENSHOTS_FOLDER + "diff/"

const shard_amount: int = 8
const run_in_paralell: bool = true

const regenerate_base_screenshots: bool = false
