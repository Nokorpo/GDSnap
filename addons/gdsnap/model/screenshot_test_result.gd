class_name ScreenshotTestResult
extends RefCounted

var diff: ComparisonResult
var start_time: float
var end_time: float
var execution_time: float
var file_path: StringName

func _init(_file_path: StringName):
	start_time = Time.get_unix_time_from_system()
	file_path = _file_path

func test_ended():
	end_time = Time.get_unix_time_from_system()
	execution_time = end_time - start_time
