# GDSnap

This is a screenshot testing/snapshot testing library for Godot.

## How does it work?

It saves a screenshot of your game and uses it as a source of truth. The next time you execute the test, it will take another screenshot and compare it to see if anything is different.

The result will look similar to this picture:

![sample execution](https://github.com/nokorpo/gdsnap/blob/main/examples/sample_result.png?raw=true)

* Cyan shows what was in the original screenshot and is no longer there.
* Red shows what is in the new image but wasn't there in the original screenshot.

With these tests you can detect issues early and without spending a lot of time setting up scenes for functional tests.

## How to use it?

### Use it on its own

For the first run, follow these instructions:

1. Create a Scene with the base node being of type ScreenshotTest. Add a name in the variable "Test name".
2. For the first execution, enable the checkbox for "Update base shot". Then run the scene. This will generate the base screenshot used to comparein the following executions.
3. Disable the "Update base shot" checkbox.

Every time you run the scene after that, it will generate a diff image under `res://screenshots/diff`. These diff images show the difference between the base shot (the original screenshot) and the one took when you run it.

You can also **run the tests from the terminal** with the help of a script. It will find all scenes in the project whose root node inherits from `ScreenshotTest` and run them. You can run it with:

```bash
godot --headless --script "res://addons/gdsnap/view/cli.gd"
```

### Or use it with a testing framework

Alternatively, you can use it with GUT, GoDotTest or any other test framework by calling the static functions:

```gdscript
# Generate the base shot
# (only run this when you want to generate/update the base shot)
GDSnap.update_base_screenshot(SCREENSHOT_NAME, get_viewport())

# Take a screenshot and compare it with the base shot
GDSnap.take_screenshot(SCREENSHOT_NAME, get_viewport())
```

The `take_screenshot` method will return an object with:
* An `int` with a count of how many pixels are different.
* The difference in percent, a `float` from 0 to 1. This means 0.1% will be 0.001.
* The generated diff image.

## Current features:

* Creates folder structure to store base/new screenshots. They are properly ignored by Git and the Godot editor.
* Run to generate the base screenshots.
* Run to compare screenshots.
* Multithreading for comparing large screenshots.

