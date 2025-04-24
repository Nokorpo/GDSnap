#!/usr/bin/env -S godot -s
extends SceneTree

const EXCLUDED_PATHS = ["res://addons"]

func _init():
	# TODO read cli params
	await root.ready
	var all_scenes: Array[PackedScene] = []
	for scene_path in _get_all_scene_files("res://", EXCLUDED_PATHS):
		var scene: PackedScene = load(scene_path)
		var script: Script = _get_scene_root_script(scene)
		if _check_if_screenshot_test(script):
			all_scenes.append(scene)

	print("GDSnap: Found %d screenshot test scenes." % all_scenes.size())
	for scene in all_scenes:
			print("GDSnap: opening test in %s." % scene.resource_path)
			var window := Window.new()
			window.size = root.get_viewport().size
			window.add_child(scene.instantiate())
			root.add_child(window)

static func _append_path(path: String, file: String) -> String:
	if path == "res://":
		return "res://%s" % file
	else:
		return "%s/%s" % [path, file]

func _get_all_scene_files(path: String, ignored_paths: PackedStringArray = [], file_ext := ".tscn", files := []) -> PackedStringArray:
	if path in ignored_paths:
		return files

	for file in DirAccess.get_files_at(path):
		if file.ends_with(file_ext):
			files.append(_append_path(path, file))

	var directories := DirAccess.get_directories_at(path)
	for dir in directories:
		var new_path: String = _append_path(path, dir)
		files.append_array(_get_all_scene_files(_append_path(path, dir), ignored_paths, file_ext, []))

	return files

## Returns a String with the class name of the root's node in an uninstantiated
## scene. If the script doesn't define a `"class_name"`, it returns an empty
## string `""`. If the script has no script, it return `null`.
func _get_scene_root_script(scene: PackedScene) -> Variant:
	var state: SceneState = scene.get_state()
	for prop in range(state.get_node_property_count(0)):
		if state.get_node_property_name(0, prop) == "script":
			return state.get_node_property_value(0, prop)
	return null

## Recursively checks if a node inherits from the ScreenshotTest class.
## Returns true if it does, false otherwise
func _check_if_screenshot_test(script: Script) -> bool:
	if script.get_global_name() == "ScreenshotTest":
		return true
	elif script.get_base_script() != null:
		return _check_if_screenshot_test(script.get_base_script())
	else:
		return false
