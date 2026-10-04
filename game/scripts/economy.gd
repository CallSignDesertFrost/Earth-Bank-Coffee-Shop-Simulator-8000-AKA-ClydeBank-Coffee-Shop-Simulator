class_name CafeEconomy
extends RefCounted
const SEASONS = ["Winter", "Spring", "Summer", "Fall"]
const WEATHER_LOW = [20, 40, 55, 35]
const WEATHER_HIGH = [74, 85, 100, 85]
const PRODUCT_COST = {"pastry": 1800, "iced": 1500, "merch": 2500}
const PRODUCT_COUNT = {"pastry": 12, "iced": 12, "merch": 4}
const PRODUCT_PRICE = {"pastry": 350, "iced": 400, "merch": 1000}
const RESERVE = 6000
var save_path := "user://cafe.json"
var rng := RandomNumberGenerator.new()
var day := 1
var cash := 100000
var beans := 100
var total_cups := 0
var temperature := 20
var temperature_f := 68
var season := 0
var pastries := 0
var iced_coffees := 0
var merch := 0
var espresso_level := 1
var oven_level := 1
var machine_broken := ""
var repair_remaining := 0.0
var broken_hours := 0
var profit_earned := 0
var investment_spent := 0
var expansion_unlocked := false
var day_revenue := 0
var day_expenses := 0
var pending_expenses := 0
var day_cups := 0
var last_profit := 0
var last_revenue := 0
var last_expenses := 0
var advertising := 0
var active_day := false
var player_name := ""
var gender := "Prefer not to say"
var character := 0
var skin := 0
var tutorial_done := false

func spend(cost: int, investment: bool = false) -> bool:
	if cost <= 0 or cost > cash: return false
	if investment and (not expansion_unlocked or cost > profit_earned - investment_spent): return false
	cash -= cost
	if investment: investment_spent += cost
	if active_day: day_expenses += cost
	else: pending_expenses += cost
	return true

func purchase(cost: int, inventory: int) -> bool:
	if inventory < 0 or not spend(cost): return false
	beans += inventory
	return true

func serve(cups: int, price: int) -> int:
	if cups <= 0 or price < 50 or machine_broken == "espresso": return 0
	var count := mini(cups, beans)
	beans -= count
	cash += count * (price - 50)
	day_revenue += count * price
	day_expenses += count * 50
	total_cups += count
	day_cups += count
	return count

func add_product(kind: String, cost: int) -> bool:
	if not PRODUCT_COST.has(kind) or cost != PRODUCT_COST[kind] or active_day or not spend(cost, true): return false
	if kind == "pastry": pastries += PRODUCT_COUNT[kind]
	elif kind == "iced": iced_coffees += PRODUCT_COUNT[kind]
	else: merch += PRODUCT_COUNT[kind]
	return true

func sell_product(kind: String) -> bool:
	if not active_day or not PRODUCT_PRICE.has(kind): return false
	if kind == "pastry":
		if pastries <= 0 or machine_broken == "oven": return false
		pastries -= 1
	elif kind == "iced":
		if iced_coffees <= 0: return false
		iced_coffees -= 1
	else:
		if merch <= 0: return false
		merch -= 1
	cash += PRODUCT_PRICE[kind]
	day_revenue += PRODUCT_PRICE[kind]
	return true

func repair_cost() -> int:
	return 1800 if machine_broken == "espresso" else 2400

func repair_machine(kind: String, cost: int) -> bool:
	if kind.is_empty() or machine_broken != kind or repair_remaining > 0 or cost != repair_cost() or not spend(cost): return false
	if active_day: repair_remaining = maxf(1, broken_hours) * 6.0
	else: machine_broken = ""
	return true

func replace_machine(kind: String) -> bool:
	if active_day or not kind in ["espresso", "oven"]: return false
	var cost := 8000 if kind == "espresso" else 6500
	if not spend(cost, true): return false
	if kind == "espresso": espresso_level += 1
	else: oven_level += 1
	if machine_broken == kind: machine_broken = ""
	repair_remaining = 0
	return true

func breakdown(kind: String, hours: int) -> void:
	if machine_broken.is_empty() and kind in ["espresso", "oven"]:
		machine_broken = kind
		broken_hours = clampi(hours, 1, 2)

func tick_repair(delta: float) -> bool:
	if repair_remaining <= 0: return false
	repair_remaining = maxf(0, repair_remaining - delta)
	if repair_remaining == 0:
		machine_broken = ""
		return true
	return false

func begin_day() -> void:
	active_day = true
	day_revenue = 0
	day_expenses = pending_expenses
	pending_expenses = 0
	day_cups = 0

func finish_day() -> void:
	last_revenue = day_revenue
	last_expenses = day_expenses
	last_profit = last_revenue - last_expenses
	if last_profit > 0:
		profit_earned += last_profit
		expansion_unlocked = true
	active_day = false
	day += 1
	advertising = 0
	if repair_remaining > 0: machine_broken = ""
	repair_remaining = 0
	roll_weather()

func roll_weather() -> void:
	season = int((day - 1) / 7) % 4
	temperature_f = rng.randi_range(WEATHER_LOW[season], WEATHER_HIGH[season])
	temperature = roundi((temperature_f - 32) * 5.0 / 9.0)

func level() -> int:
	return 1 + int(total_cups / 40)

func story() -> String:
	if not expansion_unlocked: return "Chapter 1 • A fresh start\nYou inherited a quiet corner café. Earn a profitable day to open your investment desk."
	if investment_spent == 0: return "Chapter 2 • More than coffee\nYour first regular asks for something to eat. Reinvest earnings while keeping a repair reserve."
	if espresso_level == 1 and oven_level == 1: return "Chapter 3 • Growing pains\nThe neighborhood knows your name. Diversify the menu and prepare for busy-day equipment failures."
	if cash < 125000: return "Chapter 4 • A resilient café\nReliable equipment protects sales. Build $1,250 cash without sacrificing your reserve."
	return "Chapter 5 • The neighborhood's home\nYour café is thriving. Balance growth, fair pricing, and an emergency fund through every season."

func save_game() -> Error:
	var data := {"version": 3}
	for key in fields(): data[key] = get(key)
	var file := FileAccess.open(save_path + ".tmp", FileAccess.WRITE)
	if file == null: return FileAccess.get_open_error()
	file.store_string(JSON.stringify(data))
	file.close()
	return DirAccess.rename_absolute(save_path + ".tmp", save_path)

func fields() -> Array[String]:
	return ["day", "cash", "beans", "total_cups", "temperature", "temperature_f", "season", "pastries", "iced_coffees", "merch", "espresso_level", "oven_level", "machine_broken", "repair_remaining", "broken_hours", "profit_earned", "investment_spent", "expansion_unlocked", "day_revenue", "day_expenses", "pending_expenses", "day_cups", "last_profit", "last_revenue", "last_expenses", "advertising", "active_day", "player_name", "gender", "character", "skin", "tutorial_done"]

func load_game() -> bool:
	if not FileAccess.file_exists(save_path): return false
	var data = JSON.parse_string(FileAccess.get_file_as_string(save_path))
	if not data is Dictionary: return false
	var version = data.get("version", 0)
	if not (version is int or version is float) or not int(version) in [1, 2, 3] or float(version) != int(version): return false
	for key in ["day", "cash", "beans", "total_cups", "temperature"]:
		if not data.has(key): return false
	for key in fields():
		if not data.has(key): continue
		var original = get(key)
		var value = data[key]
		if original is int or original is float:
			if not (value is float or value is int) or not is_finite(float(value)) or absf(float(value)) > 100000000: return false
			if original is int and float(value) != floor(float(value)): return false
			if not key in ["last_profit", "temperature"] and value < 0: return false
		elif original is bool:
			if not value is bool: return false
		elif not value is String: return false
	if data.day < 1 or data.get("season", 0) > 3 or data.get("character", 0) > 3 or data.get("skin", 0) > 3: return false
	if data.get("espresso_level", 1) < 1 or data.get("oven_level", 1) < 1: return false
	if data.get("investment_spent", 0) > data.get("profit_earned", 0): return false
	if data.get("broken_hours", 0) > 2 or data.get("repair_remaining", 0) > 12: return false
	if not data.get("machine_broken", "") in ["", "espresso", "oven"]: return false
	if str(data.get("player_name", "")).length() > 24: return false
	if not data.get("gender", "Prefer not to say") in ["Woman", "Man", "Nonbinary", "Prefer not to say"]: return false
	for key in fields():
		if data.has(key): set(key, data[key])
	season = int((day - 1) / 7) % 4
	temperature_f = clampi(int(data.get("temperature_f", round(temperature * 1.8 + 32))), WEATHER_LOW[season], WEATHER_HIGH[season])
	temperature = roundi((temperature_f - 32) / 1.8)
	return true
