class_name CafeEconomy
extends RefCounted
var save_path := "user://cafe.json"
var day: int = 1
var cash: int = 100000
var beans: int = 100
var total_cups: int = 0
var temperature: int = 20
var rng := RandomNumberGenerator.new()

func purchase(cost: int, inventory: int) -> bool:
	if cost <= 0 or inventory < 0 or cost > cash:
		return false
	cash -= cost
	beans += inventory
	return true

func serve(cups: int, price: int) -> int:
	if cups <= 0 or price < 50:
		return 0
	var count := mini(cups, beans)
	beans -= count
	cash += count * (price - 50)
	total_cups += count
	return count

func save_game() -> Error:
	var data := {"version": 1, "day": day, "cash": cash, "beans": beans, "total_cups": total_cups, "temperature": temperature}
	var file := FileAccess.open(save_path + ".tmp", FileAccess.WRITE)
	if file == null:
		return FileAccess.get_open_error()
	file.store_string(JSON.stringify(data))
	file.close()
	return DirAccess.rename_absolute(save_path + ".tmp", save_path)

func load_game() -> bool:
	if not FileAccess.file_exists(save_path):
		return false
	var data = JSON.parse_string(FileAccess.get_file_as_string(save_path))
	if not data is Dictionary or data.get("version") != 1:
		return false
	for key in ["day", "cash", "beans", "total_cups", "temperature"]:
		if not data.has(key) or not (data[key] is float or data[key] is int) or not is_finite(float(data[key])):
			return false
	if data.day < 1 or data.cash < 0 or data.beans < 0 or data.total_cups < 0 or data.temperature < 10 or data.temperature > 30:
		return false
	day = int(data.day)
	cash = int(data.cash)
	beans = int(data.beans)
	total_cups = int(data.total_cups)
	temperature = int(data.temperature)
	return true
