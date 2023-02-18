# GdUnit generated TestSuite
class_name GdUnitSceneRunnerTest
extends GdUnitTestSuite

# TestSuite generated from
const __source = 'res://addons/gdUnit4/src/core/GdUnitSceneRunnerImpl.gd'

# loads the test runner and register for auto freeing after test 
func load_test_scene() -> Node:
	return auto_free(load("res://addons/gdUnit4/test/mocker/resources/scenes/TestScene.tscn").instantiate())


func before():
	# use a dedicated FPS because we calculate frames by time
	Engine.set_max_fps(60)

func after():
	Engine.set_max_fps(0)

func test_get_property() -> void:
	var runner := scene_runner(load_test_scene())
	
	assert_that(runner.get_property("_box1")).is_instanceof(ColorRect)
	assert_that(runner.get_property("_invalid")).is_equal("The property '_invalid' not exist checked loaded scene.")

func test_invoke_method() -> void:
	var runner := scene_runner(load_test_scene())
	
	assert_that(runner.invoke("add", 10, 12)).is_equal(22)
	assert_that(runner.invoke("sub", 10, 12)).is_equal("The method 'sub' not exist checked loaded scene.")

func test_awaitForMilliseconds() -> void:
	var runner := scene_runner(load_test_scene())
	
	var stopwatch = LocalTime.now()
	await await_millis(1000)
	
	# verify we wait around 1000 ms (using 100ms offset because timing is not 100% accurate)
	assert_int(stopwatch.elapsed_since_ms()).is_between(900, 1100)

func test_simulate_frames(timeout = 5000) -> void:
	var runner := scene_runner(load_test_scene())
	var box1 :ColorRect = runner.get_property("_box1")
	# initial is white
	assert_object(box1.color).is_equal(Color.WHITE)
	
	# start color cycle by invoke the function 'start_color_cycle'
	runner.invoke("start_color_cycle")
	
	# we wait for 10 frames
	await runner.simulate_frames(10)
	# after 10 frame is still white
	assert_object(box1.color).is_equal(Color.WHITE)
	
	# we wait 30 more frames
	await runner.simulate_frames(30)
	# after 40 frames the box one should be changed to red
	assert_object(box1.color).is_equal(Color.RED)

func test_simulate_frames_withdelay(timeout = 4000) -> void:
	var runner := scene_runner(load_test_scene())
	var box1 :ColorRect = runner.get_property("_box1")
	# initial is white
	assert_object(box1.color).is_equal(Color.WHITE)
	
	# start color cycle by invoke the function 'start_color_cycle'
	runner.invoke("start_color_cycle")
	
	# we wait for 10 frames each with a 50ms delay
	await runner.simulate_frames(10, 50)
	# after 10 frame and in sum 500ms is should be changed to red
	assert_object(box1.color).is_equal(Color.RED)

func test_run_scene_colorcycle(timeout=2000) -> void:
	var runner := scene_runner(load_test_scene())
	var box1 :ColorRect = runner.get_property("_box1")
	# verify inital color
	assert_object(box1.color).is_equal(Color.WHITE)
	
	# start color cycle by invoke the function 'start_color_cycle'
	runner.invoke("start_color_cycle")
	
	# await for each color cycle is emited
	await runner.await_signal("panel_color_change", [box1, Color.RED])
	assert_object(box1.color).is_equal(Color.RED)
	await runner.await_signal("panel_color_change", [box1, Color.BLUE])
	assert_object(box1.color).is_equal(Color.BLUE)
	await runner.await_signal("panel_color_change", [box1, Color.GREEN])
	assert_object(box1.color).is_equal(Color.GREEN)

func test_simulate_key_pressed(timeout=2000) -> void:
	var runner := scene_runner(load_test_scene())
	
	# inital no spell is fired
	assert_object(runner.find_child("Spell")).is_null()
	
	# fire spell be pressing enter key
	runner.simulate_key_pressed(KEY_ENTER)
	# wait until next frame
	await await_idle_frame()
	
	# verify a spell is created
	assert_object(runner.find_child("Spell")).is_not_null()
	
	# wait until spell is explode after around 1s
	var spell = runner.find_child("Spell")
	await await_signal_on(spell, "spell_explode", [spell], timeout)
	
	# verify spell is removed when is explode
	assert_object(runner.find_child("Spell")).is_null()

# mock checked a runner and spy checked created spell
func test_simulate_key_pressed_in_combination_with_spy():
	var spy = spy(load_test_scene())
	# create a runner runner
	var runner := scene_runner(spy)
	
	# simulate a key event to fire a spell
	runner.simulate_key_pressed(KEY_ENTER)
	verify(spy).create_spell()
	
	var spell = runner.find_child("Spell")
	assert_that(spell).is_not_null()
	assert_that(spell.is_connected("spell_explode", Callable(spy, "_destroy_spell"))).is_true()


# temporary disable will be fixed with https://github.com/MikeSchulze/gdUnit4/pull/115
func _test_simulate_mouse_events():
	var spyed_scene = spy("res://addons/gdUnit4/test/mocker/resources/scenes/TestScene.tscn")
	var runner := scene_runner(spyed_scene)
	# test button 1 interaction
	await await_millis(1000)
	runner.set_mouse_pos(Vector2(60, 20))
	runner.simulate_mouse_button_pressed(MOUSE_BUTTON_LEFT)
	verify(spyed_scene)._on_panel_color_changed(spyed_scene._box1, Color.RED)
	verify(spyed_scene)._on_panel_color_changed(spyed_scene._box1, Color.GRAY)
	verify(spyed_scene, 0)._on_panel_color_changed(spyed_scene._box2, any_color())
	verify(spyed_scene, 0)._on_panel_color_changed(spyed_scene._box3, any_color())
	
	# test button 2 interaction
	reset(spyed_scene)
	await await_millis(1000)
	runner.set_mouse_pos(Vector2(160, 20))
	runner.simulate_mouse_button_pressed(MOUSE_BUTTON_LEFT)
	verify(spyed_scene, 0)._on_panel_color_changed(spyed_scene._box1, any_color())
	verify(spyed_scene)._on_panel_color_changed(spyed_scene._box2, Color.RED)
	verify(spyed_scene)._on_panel_color_changed(spyed_scene._box2, Color.GRAY)
	verify(spyed_scene, 0)._on_panel_color_changed(spyed_scene._box3, any_color())
	
	# test button 3 interaction (is changed after 1s to gray)
	reset(spyed_scene)
	await await_millis(1000)
	runner.set_mouse_pos(Vector2(260, 20))
	runner.simulate_mouse_button_pressed(MOUSE_BUTTON_LEFT)
	verify(spyed_scene, 0)._on_panel_color_changed(spyed_scene._box1, any_color())
	verify(spyed_scene, 0)._on_panel_color_changed(spyed_scene._box2, any_color())
	# is changed to red
	verify(spyed_scene)._on_panel_color_changed(spyed_scene._box3, Color.RED)
	# no gray
	verify(spyed_scene, 0)._on_panel_color_changed(spyed_scene._box3, Color.GRAY)
	# after one second is changed to gray
	await await_millis(1200)
	verify(spyed_scene)._on_panel_color_changed(spyed_scene._box3, Color.GRAY)

func test_await_func_without_time_factor() -> void:
	var runner := scene_runner(load_test_scene())
	await runner.await_func("color_cycle").is_equal("black")
	assert_fail(await runner.await_func("color_cycle", [], GdUnitAssert.EXPECT_FAIL).wait_until(500).is_equal("red"))\
		.has_failure_message("Expected: is equal 'red' but timed out after 500ms")

func test_await_func_with_time_factor() -> void:
	var runner := scene_runner(load_test_scene())
	
	# set max time factor to minimize waiting time checked `runner.wait_func`
	runner.set_time_factor(10)
	await runner.await_func("color_cycle").wait_until(200).is_equal("black")
	assert_fail(await runner.await_func("color_cycle", [], GdUnitAssert.EXPECT_FAIL).wait_until(100).is_equal("red"))\
		.has_failure_message("Expected: is equal 'red' but timed out after 100ms")

func test_await_signal_without_time_factor() -> void:
	var runner := scene_runner(load_test_scene())
	var box1 :ColorRect = runner.get_property("_box1")
	
	runner.invoke("start_color_cycle")
	await runner.await_signal("panel_color_change", [box1, Color.RED])
	await runner.await_signal("panel_color_change", [box1, Color.BLUE])
	await runner.await_signal("panel_color_change", [box1, Color.GREEN])
	
	# should be interrupted is will never change to Color.KHAKI
	GdAssertReports.expect_fail()
	await runner.await_signal( "panel_color_change", [box1, Color.KHAKI], 300)
	if assert_failed_at(191, "await_signal_on(panel_color_change, [%s, %s]) timed out after 300ms" % [str(box1), str(Color.KHAKI)]):
		return
	fail("test should failed after 300ms checked 'await_signal'")

func test_await_signal_with_time_factor() -> void:
	var runner := scene_runner(load_test_scene())
	var box1 :ColorRect = runner.get_property("_box1")
	# set max time factor to minimize waiting time checked `runner.wait_func`
	runner.set_time_factor(10)
	runner.invoke("start_color_cycle")
	
	await runner.await_signal("panel_color_change", [box1, Color.RED], 100)
	await runner.await_signal("panel_color_change", [box1, Color.BLUE], 100)
	await runner.await_signal("panel_color_change", [box1, Color.GREEN], 100)
	
	# should be interrupted is will never change to Color.KHAKI
	GdAssertReports.expect_fail()
	await runner.await_signal("panel_color_change", [box1, Color.KHAKI], 30)
	if assert_failed_at(209, "await_signal_on(panel_color_change, [%s, %s]) timed out after 30ms" % [str(box1), str(Color.KHAKI)]):
		return
	fail("test should failed after 30ms checked 'await_signal'")

func test_simulate_until_signal() -> void:
	var runner := scene_runner(load_test_scene())
	var box1 :ColorRect = runner.get_property("_box1")
	
	# set max time factor to minimize waiting time checked `runner.wait_func`
	runner.invoke("start_color_cycle")
	
	await runner.simulate_until_signal("panel_color_change", box1, Color.RED)
	await runner.simulate_until_signal("panel_color_change", box1, Color.BLUE)
	await runner.simulate_until_signal("panel_color_change", box1, Color.GREEN)
	#await runner.wait_emit_signal(runner, "panel_color_change", [runner._box1, Color.KHAKI], 30, GdUnitAssert.EXPECT_FAIL)\
	#	.starts_with_failure_message("Expecting emit signal: 'panel_color_change(")

func test_simulate_until_object_signal(timeout=2000) -> void:
	var runner := scene_runner(load_test_scene())
	
	# inital no spell is fired
	assert_object(runner.find_child("Spell")).is_null()
	
	# fire spell be pressing enter key
	runner.simulate_key_pressed(KEY_ENTER)
	# wait until next frame
	await await_idle_frame()
	var spell = runner.find_child("Spell")
	prints(spell)
	
	# simmulate scene until the spell is explode
	await runner.simulate_until_object_signal(spell, "spell_explode", spell)
	
	# verify spell is removed when is explode
	assert_object(runner.find_child("Spell")).is_null()

func test_runner_by_null_instance() -> void:
	var runner := scene_runner(null)
	assert_object(runner.scene()).is_null()

func test_runner_by_invalid_resource_path() -> void:
	# not existing scene
	assert_object(scene_runner("res://test_scene.tscn").scene()).is_null()
	# not a path to a scene
	assert_object(scene_runner("res://addons/gdUnit4/test/core/resources/scenes/simple_scene.gd").scene()).is_null()

func test_runner_by_resource_path() -> void:
	var runner = scene_runner("res://addons/gdUnit4/test/core/resources/scenes/simple_scene.tscn")
	assert_object(runner.scene()).is_instanceof(Node2D)
	
	# verify the scene is freed when the runner is freed
	var scene = runner.scene()
	assert_bool(is_instance_valid(scene)).is_true()
	runner._notification(NOTIFICATION_PREDELETE)
	# give engine time to free the resources
	await await_idle_frame()
	# verify runner and scene is freed
	assert_bool(is_instance_valid(scene)).is_false()

func test_runner_by_invalid_scene_instance() -> void:
	var scene = RefCounted.new()
	var runner := scene_runner(scene)
	assert_object(runner.scene()).is_null()

func test_runner_by_scene_instance() -> void:
	var scene = load("res://addons/gdUnit4/test/core/resources/scenes/simple_scene.tscn").instantiate()
	var runner := scene_runner(scene)
	assert_object(runner.scene()).is_instanceof(Node2D)
	
	# verify the scene is freed when the runner is freed
	runner._notification(NOTIFICATION_PREDELETE)
	# give engine time to free the resources
	await await_idle_frame()
	# verify runner and scene is freed
	assert_bool(is_instance_valid(scene)).is_false()

# we override the scene runner function for test purposes to hide push_error notifications
func scene_runner(scene, verbose := false) -> GdUnitSceneRunner:
	return auto_free(GdUnitSceneRunnerImpl.new(weakref(self), scene, verbose, true))
