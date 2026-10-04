extends SceneTree
const Economy = preload("res://scripts/economy.gd")
func _initialize() -> void:
	var e := Economy.new()
	e.save_path = "user://test-cafe.json"
	assert(not e.purchase(-100, 100))
	assert(not e.purchase(100001, 100))
	assert(e.cash == 100000 and e.beans == 100)
	assert(e.purchase(1000, 100))
	assert(e.beans == 200 and e.cash == 99000)
	e.beans = 2
	assert(e.serve(3, 300) == 2)
	assert(e.beans == 0 and e.cash == 99500)
	assert(e.serve(1, 300) == 0)
	assert(e.serve(1, -100) == 0)
	# Use an isolated user directory when invoking this suite.
	assert(e.save_game() == OK)
	var restored := Economy.new()
	restored.save_path = e.save_path
	assert(restored.load_game())
	assert(restored.cash == e.cash and restored.beans == 0)
	var file := FileAccess.open("user://test-cafe.json", FileAccess.WRITE)
	file.store_string('{"version":1,"day":-1}')
	file.close()
	assert(not restored.load_game())
	DirAccess.remove_absolute("user://test-cafe.json")
	print("PASS: invalid purchases, inventory limits, cent accounting, save round-trip, corrupt save rejection")
	call_deferred("integration")
func integration() -> void:
	var scene = load("res://scenes/cafe.tscn").instantiate()
	scene.economy.save_path = "user://integration-cafe.json"
	DirAccess.remove_absolute(scene.economy.save_path)
	root.add_child(scene)
	scene.economy.rng.seed = 42
	scene.open_day()
	for i in range(3000):
		scene._process(0.1)
		if not scene.running:
			break
	assert(not scene.running)
	assert(scene.economy.day == 2)
	assert(scene.customers.is_empty())
	assert(scene.economy.beans >= 0)
	print("PASS: full animated customer day completes and advances")
	DirAccess.remove_absolute(scene.economy.save_path)
	quit()
