extends Node3D
const Economy = preload("res://scripts/economy.gd")
var economy := Economy.new()
var customers: Array[Node3D] = []
var stats: Label
var message: Label
var price: SpinBox
var open_button: Button
var stock_button: Button
var ad_button: Button
var pause_button: Button
var running := false
var paused := false
var advertising := 0
var remaining := 0
var cups_today := 0
var day_start_cash := 0
var elapsed := 0.0
var arrival := 0.0
var palette := [Color("b86c47"), Color("4b827b"), Color("bca05e"), Color("687ca8")]

func _ready() -> void:
	economy.rng.randomize()
	economy.load_game()
	build_cafe()
	build_ui()
	refresh()

func material(color: Color) -> StandardMaterial3D:
	var result := StandardMaterial3D.new()
	result.albedo_color = color
	result.roughness = 0.85
	return result

func box(parent: Node3D, size: Vector3, at: Vector3, color: Color) -> MeshInstance3D:
	var mesh := MeshInstance3D.new()
	var shape := BoxMesh.new()
	shape.size = size
	mesh.mesh = shape
	mesh.material_override = material(color)
	parent.add_child(mesh)
	mesh.position = at
	return mesh

func sphere(parent: Node3D, radius: float, at: Vector3, color: Color) -> void:
	var node := MeshInstance3D.new()
	var mesh := SphereMesh.new()
	mesh.radius = radius
	mesh.height = radius * 2
	mesh.radial_segments = 12
	mesh.rings = 6
	node.mesh = mesh
	node.material_override = material(color)
	parent.add_child(node)
	node.position = at

func sign_text(words: String, at: Vector3, font_size: int) -> void:
	var label := Label3D.new()
	label.text = words
	label.font_size = font_size
	label.position = at
	label.modulate = Color("fff0d3")
	add_child(label)

func build_cafe() -> void:
	var world := WorldEnvironment.new()
	var environment := Environment.new()
	environment.background_mode = Environment.BG_COLOR
	environment.background_color = Color("182b2c")
	environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	environment.ambient_light_color = Color("ffe3bb")
	environment.ambient_light_energy = 0.65
	world.environment = environment
	add_child(world)
	var light := DirectionalLight3D.new()
	light.rotation_degrees = Vector3(-55, -25, 0)
	light.light_color = Color("ffe6c0")
	light.light_energy = 1.1
	add_child(light)
	var camera := Camera3D.new()
	add_child(camera)
	camera.position = Vector3(10, 11, 14)
	camera.look_at(Vector3(0, 0.8, 0))
	camera.projection = Camera3D.PROJECTION_ORTHOGONAL
	camera.size = 16
	camera.current = true
	box(self, Vector3(12, 0.2, 10), Vector3(0, -0.1, 0), Color("c5aa85"))
	for x in range(-5, 6):
		box(self, Vector3(0.025, 0.01, 10), Vector3(x, 0.015, 0), Color("aa8e6d"))
	box(self, Vector3(12, 4, 0.2), Vector3(0, 2, -5), Color("2d5752"))
	box(self, Vector3(0.2, 4, 10), Vector3(-6, 2, 0), Color("e6d5b7"))
	box(self, Vector3(7, 1.3, 1.4), Vector3(-0.5, 0.65, -2), Color("6f4532"))
	box(self, Vector3(7.3, 0.15, 1.6), Vector3(-0.5, 1.35, -2), Color("f3e6ce"))
	box(self, Vector3(1.2, 0.8, 0.7), Vector3(-1.5, 1.8, -2), Color("354349"))
	for x in [-1.8, -1.3]:
		box(self, Vector3(0.15, 0.35, 0.15), Vector3(x, 1.7, -1.55), Color("c4c9c6"))
	for x in [-4, 0, 4]:
		box(self, Vector3(2, 0.12, 0.5), Vector3(x, 2.5, -4.7), Color("8f6343"))
		for dx in [-0.6, 0, 0.6]:
			box(self, Vector3(0.25, 0.45, 0.25), Vector3(x + dx, 2.8, -4.7), Color("c59456"))
	for x in [-3.5, 1.0]:
		box(self, Vector3(1.8, 0.15, 1.6), Vector3(x, 1, 1.7), Color("996644"))
		box(self, Vector3(0.25, 1, 0.25), Vector3(x, 0.5, 1.7), Color("354b48"))
		for z in [0.4, 3.0]:
			box(self, Vector3(0.8, 0.12, 0.8), Vector3(x, 0.55, z), Color("3d746e"))
			box(self, Vector3(0.7, 0.65, 0.12), Vector3(x, 0.9, z + 0.3), Color("3d746e"))
	for x in [-5, 5]:
		box(self, Vector3(0.7, 0.7, 0.7), Vector3(x, 0.35, -3.8), Color("af714a"))
		for h in [0.8, 1.1, 1.4]:
			sphere(self, 0.45, Vector3(x, h, -3.8), Color("4c7850"))
	sign_text("T E Z C A T T   /   C O F F E E", Vector3(0, 3.4, -4.8), 64)
	sign_text("SMALL BATCH. BIG DREAMS.", Vector3(0, 2.9, -4.8), 32)

func build_ui() -> void:
	var layer := CanvasLayer.new()
	add_child(layer)
	var root := Control.new()
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	layer.add_child(root)
	var panel := PanelContainer.new()
	panel.position = Vector2(24, 24)
	panel.custom_minimum_size = Vector2(330, 0)
	root.add_child(panel)
	var margin := MarginContainer.new()
	for side in ["left", "top", "right", "bottom"]:
		margin.add_theme_constant_override("margin_" + side, 18)
	panel.add_child(margin)
	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 12)
	margin.add_child(column)
	var title := Label.new()
	title.text = "TEZCATT • COFFEE SHOP"
	title.add_theme_font_size_override("font_size", 24)
	column.add_child(title)
	stats = Label.new()
	stats.add_theme_font_size_override("font_size", 20)
	column.add_child(stats)
	var hint := Label.new()
	hint.text = "Set your price. Stock up. Open the café."
	column.add_child(hint)
	price = SpinBox.new()
	price.min_value = 0.5
	price.max_value = 12
	price.step = 0.25
	price.value = 3
	price.prefix = "Cup price $"
	price.custom_minimum_size.y = 52
	column.add_child(price)
	stock_button = button(column, "Buy 100 beans • $10", buy_stock)
	ad_button = button(column, "Local advertising • $5", buy_ad)
	open_button = button(column, "OPEN CAFÉ", open_day)
	pause_button = button(column, "Pause", toggle_pause)
	pause_button.disabled = true
	message = Label.new()
	message.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	message.custom_minimum_size = Vector2(290, 100)
	message.text = "Welcome! Weather and advertising bring visitors.\nServe coffee to grow your shop."
	column.add_child(message)

func button(parent: Node, text: String, action: Callable) -> Button:
	var node := Button.new()
	node.text = text
	node.custom_minimum_size.y = 52
	node.pressed.connect(action)
	parent.add_child(node)
	return node

func refresh() -> void:
	stats.text = "DAY %d   •   %d°C\nCash $%.2f   |   Beans %d\nLifetime cups served: %d" % [economy.day, economy.temperature, economy.cash / 100.0, economy.beans, economy.total_cups]
	stock_button.disabled = running or economy.cash < 1000
	ad_button.disabled = running or economy.cash < 500
	open_button.disabled = running or economy.beans == 0
	price.editable = not running

func buy_stock() -> void:
	if economy.purchase(1000, 100):
		economy.save_game()
		refresh()

func buy_ad() -> void:
	if economy.purchase(500, 0):
		advertising += 5
		message.text = "Advertising booked for today's visitors."
		# Pre-day ads intentionally remain session-only; save after the day.
		refresh()

func open_day() -> void:
	running = true
	paused = false
	pause_button.disabled = false
	remaining = clampi(int((economy.temperature - 10) * 0.8 + advertising / 5.0), 1, 14)
	cups_today = 0
	day_start_cash = economy.cash
	arrival = 0
	message.text = "Doors open. Your first customer is on the way!"
	refresh()

func toggle_pause() -> void:
	paused = not paused
	pause_button.text = "Resume" if paused else "Pause"

func spawn_customer() -> void:
	var person := Node3D.new()
	add_child(person)
	person.position = Vector3(5, 0, 4)
	var color: Color = palette[economy.rng.randi_range(0, 3)]
	box(person, Vector3(0.5, 0.65, 0.3), Vector3(0, 1.0, 0), color)
	sphere(person, 0.24, Vector3(0, 1.6, 0), Color("ce9a76"))
	sphere(person, 0.245, Vector3(0, 1.72, -0.035), Color("40352d"))
	for x in [-0.17, 0.17]:
		var leg := box(person, Vector3(0.18, 0.65, 0.2), Vector3(x, 0.35, 0), Color("33434d"))
		leg.name = "LeftLeg" if x < 0 else "RightLeg"
		box(person, Vector3(0.17, 0.6, 0.2), Vector3(x * 2, 1.0, 0), color)
	person.set_meta("age", 0.0)
	person.set_meta("served", false)
	customers.append(person)

func _process(delta: float) -> void:
	if paused or not running:
		return
	elapsed += delta
	arrival -= delta
	if remaining > 0 and arrival <= 0:
		spawn_customer()
		remaining -= 1
		arrival = 2.5
	for person in customers.duplicate():
		var age: float = person.get_meta("age") + delta
		person.set_meta("age", age)
		var destination := Vector3(1.8, 0, -0.9) if not person.get_meta("served") else Vector3(6.5, 0, 4.5)
		var movement: Vector3 = destination - person.position
		if movement.length() > 0.15:
			person.position = person.position.move_toward(destination, delta * 2)
			person.rotation.y = atan2(movement.x, movement.z)
			person.get_node("LeftLeg").rotation.x = sin(age * 10) * 0.45
			person.get_node("RightLeg").rotation.x = -sin(age * 10) * 0.45
		elif not person.get_meta("served"):
			var chance := clampf((economy.temperature - 10) / 20.0 * 0.6 + 0.2 + advertising / 200.0, 0.1, 1.0)
			chance *= minf(1.0, 3.0 / price.value)
			if economy.rng.randf() < chance:
				var count := economy.serve(1 + int(price.value <= 2) + int(economy.temperature >= 20), int(round(price.value * 100)))
				cups_today += count
				message.text = "Served %d cups. Thank you for stopping by!" % count if count > 0 else "Sold out! Restock before tomorrow."
			else:
				message.text = "A visitor browsed the menu. Try a lower price."
			person.set_meta("served", true)
			refresh()
		else:
			customers.erase(person)
			person.queue_free()
	if remaining == 0 and customers.is_empty():
		running = false
		pause_button.disabled = true
		var earned := (economy.cash - day_start_cash) / 100.0
		message.text = "DAY COMPLETE • %d cups\nSales less serving costs: $%.2f\nRestock and open again tomorrow." % [cups_today, earned]
		economy.day += 1
		economy.temperature = economy.rng.randi_range(10, 30)
		advertising = 0
		if economy.save_game() != OK:
			message.text += "\nSave failed. Keep the app open."
		refresh()

func _notification(what: int) -> void:
	if what == NOTIFICATION_APPLICATION_PAUSED and running and not paused:
		toggle_pause()
