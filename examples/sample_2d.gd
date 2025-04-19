extends Node2D
## This script shows a sample of how to use the GDSnap plugin to run screenshot
## tests without using its built-in test suite. This method should be adaptable
## to other testing frameworks like GUT or GoDotTest.

## Set to true when you need to regenerate the screenshot
const UPDATE_SHOT: bool = false

## How accurate the result should be for the test to be successful
const OK_THRESHOLD: float = 0.001

## Name with which the screenshot will be stored
const SCREENSHOT_NAME := "collision_test_01"

@export var ball: RigidBody2D
@export var particles: CPUParticles2D


func _ready() -> void:
	# GIVEN the ball contacts with the ground
	ball.body_entered.connect(_take_screenshot.unbind(1))
	# AND the particles have a static seed
	particles.use_fixed_seed = true
	particles.seed = 1

func _take_screenshot() -> void:
	# AND the particles have had some time to start
	await get_tree().create_timer(0.1).timeout

	# WHEN taking a screenshot and comparing it
	if UPDATE_SHOT:
		GDSnap.update_base_screenshot(SCREENSHOT_NAME, get_viewport())
	var result := GDSnap.take_screenshot(SCREENSHOT_NAME, get_viewport())

	#THEN it should look similar (under OK_THRESHOLD)
	print("The screenshots are %f%% different" % result.difference_by_percent)
	assert(result.difference_by_percent <= OK_THRESHOLD)

	get_tree().quit()
