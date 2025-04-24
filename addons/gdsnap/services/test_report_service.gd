class_name TestReportService
extends RefCounted

var _results: Dictionary = {}

func on_test_begin(test: ScreenshotTest) -> void:
	_results[test] = ScreenshotTestResult.new(test.scene_file_path)

func on_test_end(test: ScreenshotTest, diff_result: ComparisonResult) -> void:
	var test_result: ScreenshotTestResult = _results[test]
	test_result.diff = diff_result
	test_result.test_ended()

func generate_results_file() -> StringName:
	var file_content: PackedStringArray = ["<?xml version=\"1.0\" encoding=\"UTF-8\"?>"]
	file_content.append(generate_test_suite_summary())
	file_content.append_array(generate_test_case_list())
	file_content.append("</testsuite>")

	var file := FileAccess.open(ScreenshotConfig.RESULT_FILE_PATH, FileAccess.WRITE)
	file.store_string("\n".join(file_content))
	return ScreenshotConfig.RESULT_FILE_PATH

func generate_test_suite_summary() -> String:
	var test_count := 0
	var execution_time := 0.0
	var failures := 0
	var errors := 0
	var skipped := 0
	for result: ScreenshotTestResult in _results.values():
		test_count += 1
		execution_time += result.execution_time
		if result.diff == ComparisonResult.UPDATED:
			skipped += 1
		elif result.diff == ComparisonResult.TIMEOUT:
			errors += 1
		elif result.diff == ComparisonResult.ERROR:
			errors += 1
		elif result.diff.difference_by_percent >= ScreenshotConfig.instance.failure_threshold:
			failures += 1
	return "<testsuite time=\"%f\" tests=\"%d\" failures=\"%d\" errors=\"%d\" skipped=\"%d\">" % [execution_time, test_count, failures, errors, skipped]

func generate_test_case_list() -> PackedStringArray:
	var test_case_list: PackedStringArray = []
	for test in _results.keys():
		var result: ScreenshotTestResult = _results[test]
		test_case_list.append("    <testcase name=\"%s\" classname=\"%s\" time=\"%f\">" % [test.test_name, result.file_path, result.execution_time])
		if result.diff == ComparisonResult.UPDATED:
			test_case_list.append("        <skipped message=\"The base screenshot was updated, therefore no tests were run on it\"></error>")
		elif result.diff == ComparisonResult.TIMEOUT:
			test_case_list.append("        <error message=\"The screenshot was not taken before the timeout\" type=\"ExpectationError\"></error>")
		elif result.diff == ComparisonResult.ERROR:
			test_case_list.append("        <error message=\"An error occured while running the screenshot test. Does the base screenshot file exist? Try regenerating it.\" type=\"ExecutionError\"></error>")
		elif result.diff.difference_by_percent >= ScreenshotConfig.instance.failure_threshold:
			test_case_list.append("        <failure message=\"The screenshot is %3.2f%% different\" type=\"AssertionError\"></error>" % (result.diff.difference_by_percent * 100))
		test_case_list.append("    </testcase>")
	return test_case_list
