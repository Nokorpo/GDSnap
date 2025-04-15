class_name DiffData
extends Node

static var ERROR: DiffData = DiffData.new(-1, -1, [])

var difference_by_percent: float = 0
var different_pixels: int = 0
var data: PackedByteArray = []

func _init(_difference_by_percent: float, _different_pixels: int, _data: PackedByteArray):
	difference_by_percent = _difference_by_percent
	different_pixels = _different_pixels
	data = _data
