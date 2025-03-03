class_name DiffResult
extends Node

var different_pixels: int = 0
var diff_image: PackedByteArray = PackedByteArray()

func _init(_different_pixels: int, _diff_image: PackedByteArray):
	different_pixels = _different_pixels
	diff_image = _diff_image
