extends Node

func _ready() -> void:
	var script := load("res://addons/gdsnap/core/base_screenshot_test.gd") as GDScript
	var node := Node.new()
	node.set_script(script)
	add_child(node)
