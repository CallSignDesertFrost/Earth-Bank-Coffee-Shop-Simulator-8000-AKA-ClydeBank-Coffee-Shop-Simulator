extends SceneTree
const Economy = preload("res://scripts/economy.gd")
var checks := 0
var failed := false

func check(condition: bool, description: String) -> void:
	checks += 1
	if not condition:
		failed = true
		push_error("FAIL: " + description)

func _initialize() -> void:
	var e := Economy.new()
	e.save_path = "user://test-cafe.json"
	check(not e.purchase(-100, 100), "negative purchase rejected")
	check(not e.purchase(100001, 100), "unaffordable purchase rejected")
	check(not e.add_product("pastry", 1800), "expansion locked before profit")
	e.purchase(1000, 100)
	e.begin_day()
	e.beans = 2
	check(e.serve(3, 300) == 2, "stock-limited serving")
	check(e.cash == 99500 and e.beans == 0, "integer-cent cash")
	check(e.day_revenue == 600 and e.day_expenses == 1100, "stock and serving expenses included")
	e.finish_day()
	check(e.last_profit == -500 and not e.expansion_unlocked, "revenue does not falsely unlock expansion")
	e.begin_day()
	e.beans = 100
	e.serve(20, 300)
	e.finish_day()
	check(e.last_profit == 5000 and e.expansion_unlocked, "true profit unlocks investment desk")
	check(not e.add_product("unknown", 100), "unknown product rejected without spending")
	check(not e.add_product("pastry", -10), "invalid cost rejected")
	check(e.add_product("pastry", 1800), "earned profits buy stock")
	check(e.add_product("iced", 1500), "second product diversified")
	check(not e.add_product("merch", 2500), "investments cannot exceed earned profits")
	e.begin_day()
	e.breakdown("oven", 2)
	check(not e.sell_product("pastry"), "broken oven stops pastries")
	check(e.sell_product("iced"), "unaffected iced drink sells during oven failure")
	check(not e.repair_machine("oven", -1), "negative repair rejected")
	check(e.repair_machine("oven", 2400), "paid repair accepted")
	check(not e.repair_machine("oven", 2400), "repair cannot be double charged")
	check(not e.tick_repair(6) and e.machine_broken == "oven", "two-hour repair lasts first hour")
	check(e.tick_repair(6) and e.machine_broken.is_empty(), "repair completes after two hours")
	check(e.sell_product("pastry"), "pastries sell after oven repair")
	e.breakdown("espresso", 1)
	check(e.serve(1, 300) == 0, "broken espresso blocks coffee")
	e.finish_day()
	e.profit_earned = 20000
	check(e.replace_machine("espresso"), "profit-funded replacement")
	check(e.espresso_level == 2 and e.machine_broken.is_empty(), "replacement clears fault and raises reliability")
	for d in range(1, 113):
		e.day = d
		for sample in range(8):
			e.roll_weather()
			check(e.temperature_f >= Economy.WEATHER_LOW[e.season] and e.temperature_f <= Economy.WEATHER_HIGH[e.season], "seasonal Fahrenheit bounds")
			check(absf(e.temperature - (e.temperature_f - 32) / 1.8) <= 0.5, "Celsius conversion")
	e.player_name = "Chris"
	e.gender = "Nonbinary"
	e.character = 3
	e.skin = 2
	e.tutorial_done = true
	check(e.save_game() == OK, "save succeeds")
	var restored := Economy.new()
	restored.save_path = e.save_path
	check(restored.load_game(), "seasonal state load succeeds")
	check(restored.player_name == "Chris" and restored.character == 3 and restored.skin == 2 and restored.tutorial_done, "profile round-trip")
	check(restored.profit_earned == e.profit_earned and restored.espresso_level == 2, "investment round-trip")
	var file := FileAccess.open(e.save_path, FileAccess.WRITE)
	file.store_string('{"version":3,"day":1,"cash":100,"beans":10,"total_cups":0,"temperature":20,"season":9}')
	file.close()
	check(not restored.load_game() and restored.player_name == "Chris", "bad save rejected atomically")
	DirAccess.remove_absolute(e.save_path)
	call_deferred("integration")

func integration() -> void:
	var scene = load("res://scenes/cafe.tscn").instantiate()
	scene.economy.save_path = "user://integration-cafe.json"
	DirAccess.remove_absolute(scene.economy.save_path)
	root.add_child(scene)
	check(scene.setup_panel.visible, "entrance shown on first launch")
	scene.setup_name.text = ""
	scene.accept_setup()
	check(scene.setup_panel.visible, "empty name cannot start")
	scene.setup_name.text = "Chris"
	scene.setup_style.select(2)
	scene.setup_skin.select(3)
	scene.setup_gender.select(1)
	scene.accept_setup()
	check(scene.tutorial_panel.visible and scene.economy.gender == "Man", "name and gender accepted")
	for i in range(4): scene.advance_tutorial()
	check(scene.economy.tutorial_done and not scene.tutorial_panel.visible, "tutorial completes")
	scene.economy.rng.seed = 42
	scene.open_day()
	scene.toggle_pause()
	var clock: float = scene.elapsed
	scene._process(2)
	check(scene.elapsed == clock, "pause freezes simulation")
	scene.toggle_pause()
	for i in range(4000):
		scene._process(0.1)
		if not scene.running: break
	check(not scene.running and scene.economy.day == 2 and scene.customers.is_empty(), "full animated day completes")
	check(scene.economy.last_profit > 0 and scene.upgrade_panel.visible, "profitable day opens second panel")
	scene.buy_pastries()
	check(scene.economy.pastries == 12, "investment panel stocks pastries")
	check(scene.product_display.get_child_count() > 0, "purchased stock appears in 3D")
	var saved := Economy.new()
	saved.save_path = scene.economy.save_path
	check(saved.load_game() and saved.player_name == "Chris" and saved.pastries == 12, "gameplay profile and stock persisted")
	# Interrupt after real sales: reload retains earned cash and closes the day once.
	scene.open_day()
	scene.economy.serve(3, 300)
	scene.checkpoint()
	var reload_scene = load("res://scenes/cafe.tscn").instantiate()
	reload_scene.economy.save_path = scene.economy.save_path
	root.add_child(reload_scene)
	check(not reload_scene.economy.active_day and reload_scene.economy.day == 3, "interrupted day closes on reload")
	check(reload_scene.economy.cash == scene.economy.cash, "interrupt preserves cash without duplicating sales")
	DirAccess.remove_absolute(scene.economy.save_path)
	print("%s: %d checks — seasons, products, repairs, profile, tutorial, ledger, full day, interruption" % ["PASS" if not failed else "FAIL", checks])
	quit(1 if failed else 0)
