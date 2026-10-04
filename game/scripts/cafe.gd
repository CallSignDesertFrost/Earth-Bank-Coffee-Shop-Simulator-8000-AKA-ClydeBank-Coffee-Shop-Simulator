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
var upgrade_panel: PanelContainer
var investment_button: Button
var story_label: Label
var ledger_label: Label
var replace_espresso: Button
var replace_oven: Button
var setup_panel: PanelContainer
var setup_name: LineEdit
var setup_gender: OptionButton
var setup_style: OptionButton
var setup_skin: OptionButton
var setup_preview: Node3D
var tutorial_panel: PanelContainer
var tutorial_label: Label
var tutorial_button: Button
var tutorial_step := 0
var player_avatar: Node3D
var product_display: Node3D
var seasonal_windows: Array[MeshInstance3D] = []
var failure_checked := false
var day_duration := 60.0
var status_clock: Label
var repair_button: Button
var pastry_button: Button
var iced_button: Button
var merch_button: Button
var running := false
var paused := false
var remaining := 0
var cups_today := 0
var day_start_cash := 0
var elapsed := 0.0
var arrival := 0.0
var palette := [Color("b86c47"), Color("4b827b"), Color("687ca8"), Color("bca05e")]
var season_names := ["Winter", "Spring", "Summer", "Fall"]

func _ready() -> void:
	economy.rng.randomize()
	var loaded := economy.load_game()
	if not loaded: economy.roll_weather()
	if economy.active_day:
		economy.finish_day()
		economy.save_game()
	build_cafe()
	build_ui()
	build_player()
	update_products()
	if economy.player_name.is_empty(): show_setup()
	elif not economy.tutorial_done: show_tutorial()
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
	mesh.radial_segments = 24
	mesh.rings = 12
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
	light.shadow_enabled = true
	add_child(light)
	var camera := Camera3D.new()
	add_child(camera)
	camera.position = Vector3(10, 11, 14)
	camera.look_at(Vector3(-2.2, 0.8, 0))
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
			for dx in [-0.27, 0.27]:
				for dz in [-0.27, 0.27]:
					cylinder(self, 0.035, 0.5, Vector3(x + dx, 0.25, z + dz), Color("785b42"))
	for x in [-5, 5]:
		box(self, Vector3(0.7, 0.7, 0.7), Vector3(x, 0.35, -3.8), Color("af714a"))
		for h in [0.8, 1.1, 1.4]:
			sphere(self, 0.45, Vector3(x, h, -3.8), Color("4c7850"))
	sign_text("T E Z C A T T   /   C O F F E E", Vector3(0, 3.4, -4.8), 64)
	sign_text("SMALL BATCH. BIG DREAMS.", Vector3(0, 2.9, -4.8), 32)
	# Framed windows, pendants, rug and detailed equipment.
	for x in [-3.4, 3.8]:
		box(self, Vector3(2.4, 1.6, 0.15), Vector3(x, 1.5, -4.84), Color("d4ad70"))
		seasonal_windows.append(box(self, Vector3(2.15, 1.35, 0.17), Vector3(x, 1.5, -4.72), Color("a2c8cb")))
		box(self, Vector3(0.06, 1.35, 0.2), Vector3(x, 1.5, -4.6), Color("f6e1bc"))
		box(self, Vector3(2.15, 0.06, 0.2), Vector3(x, 1.5, -4.6), Color("f6e1bc"))
	for x in [-2.8, 0.8, 3.5]:
		cylinder(self, 0.025, 0.8, Vector3(x, 3.65, -1.8), Color("40372e"))
		cylinder(self, 0.32, 0.22, Vector3(x, 3.2, -1.8), Color("c58b48"))
		var lamp := OmniLight3D.new()
		lamp.position = Vector3(x, 3.0, -1.8)
		lamp.light_color = Color("ffd799")
		lamp.light_energy = 0.45
		lamp.omni_range = 4
		add_child(lamp)
	box(self, Vector3(5.8, 0.025, 2.3), Vector3(-1.3, 0.025, 3.6), Color("476e67"))
	for x in [-3.5, 1.0]:
		cylinder(self, 0.13, 0.18, Vector3(x, 1.2, 1.7), Color("f2e5cc"))
		cylinder(self, 0.1, 0.015, Vector3(x, 1.3, 1.7), Color("593a27"))
	box(self, Vector3(0.9, 0.6, 0.65), Vector3(2.3, 1.72, -2), Color("b1aaa0"))
	box(self, Vector3(0.68, 0.33, 0.03), Vector3(2.3, 1.7, -1.66), Color("27383a"))
	for x in [-1.8, -1.5, -1.2]:
		sphere(self, 0.045, Vector3(x, 2.03, -1.62), Color("d7ba7e"))
	product_display = Node3D.new()
	add_child(product_display)

func cylinder(parent: Node3D, radius: float, height: float, at: Vector3, color: Color) -> MeshInstance3D:
	var node := MeshInstance3D.new()
	var mesh := CylinderMesh.new()
	mesh.top_radius = radius
	mesh.bottom_radius = radius
	mesh.height = height
	mesh.radial_segments = 24
	node.mesh = mesh
	node.material_override = material(color)
	parent.add_child(node)
	node.position = at
	return node

func character_model(style: int, skin_index: int) -> Node3D:
	var person := Node3D.new()
	var skin_color: Color = [Color("f0cbb0"), Color("ce9a76"), Color("946342"), Color("583c30")][skin_index]
	var outfit: Color = palette[style]
	cylinder(person, 0.27, 0.65, Vector3(0, 1.0, 0), outfit)
	box(person, Vector3(0.34, 0.55, 0.03), Vector3(0, 0.94, 0.26), Color("ead9b5"))
	sphere(person, 0.24, Vector3(0, 1.6, 0), skin_color)
	sphere(person, 0.245, Vector3(0, 1.73, -0.045), Color("40352d"))
	if style == 1 or style == 3:
		box(person, Vector3(0.45, 0.35, 0.15), Vector3(0, 1.52, -0.15), Color("40352d"))
	if style == 2:
		cylinder(person, 0.29, 0.12, Vector3(0, 1.86, 0), outfit)
	for x in [-0.08, 0.08]:
		sphere(person, 0.027, Vector3(x, 1.64, 0.22), Color("222e30"))
	sphere(person, 0.042, Vector3(0, 1.55, 0.235), skin_color.lightened(0.12))
	for x in [-0.17, 0.17]:
		var leg := cylinder(person, 0.09, 0.6, Vector3(x, 0.37, 0), Color("33434d"))
		leg.name = "LeftLeg" if x < 0 else "RightLeg"
		box(person, Vector3(0.2, 0.12, 0.34), Vector3(x, 0.09, 0.06), Color("2b3232"))
		cylinder(person, 0.085, 0.5, Vector3(x * 2, 1, 0), outfit)
		sphere(person, 0.09, Vector3(x * 2, 0.72, 0), skin_color)
	return person

func build_player() -> void:
	if is_instance_valid(player_avatar):
		remove_child(player_avatar)
		player_avatar.queue_free()
	player_avatar = character_model(economy.character, economy.skin)
	add_child(player_avatar)
	player_avatar.position = Vector3(0, 0, -3.0)
	player_avatar.rotation.y = 0

func label_in(parent: Node, words: String, size: int = 18) -> Label:
	var label := Label.new()
	label.text = words
	label.add_theme_font_size_override("font_size", size)
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	parent.add_child(label)
	return label

func styled_panel(root: Control, at: Vector2, size: Vector2) -> PanelContainer:
	var panel := PanelContainer.new()
	panel.position = at
	panel.custom_minimum_size = size
	var style := StyleBoxFlat.new()
	style.bg_color = Color("192d2e")
	style.border_color = Color("b99055")
	style.set_border_width_all(1)
	style.set_corner_radius_all(14)
	style.content_margin_left = 18
	style.content_margin_right = 18
	style.content_margin_top = 16
	style.content_margin_bottom = 16
	panel.add_theme_stylebox_override("panel", style)
	root.add_child(panel)
	return panel

func panel_column(panel: PanelContainer, scroll_height: float = 0) -> VBoxContainer:
	var host: Node = panel
	if scroll_height > 0:
		var scroll := ScrollContainer.new()
		scroll.custom_minimum_size.y = scroll_height
		scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
		panel.add_child(scroll)
		host = scroll
	var column := VBoxContainer.new()
	column.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	column.add_theme_constant_override("separation", 9)
	host.add_child(column)
	return column

func button(parent: Node, words: String, action: Callable) -> Button:
	var node := Button.new()
	node.text = words
	node.custom_minimum_size.y = 44
	node.pressed.connect(action)
	parent.add_child(node)
	return node

func build_ui() -> void:
	var layer := CanvasLayer.new()
	add_child(layer)
	var root := Control.new()
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var theme := Theme.new()
	theme.default_font_size = 18
	for state in ["normal", "hover", "pressed", "disabled"]:
		var style := StyleBoxFlat.new()
		style.bg_color = Color("35544e") if state == "normal" else Color("527568")
		if state == "disabled": style.bg_color = Color("273938")
		style.set_corner_radius_all(8)
		style.set_border_width_all(1)
		style.border_color = Color("b99055") if state != "disabled" else Color("40524e")
		theme.set_stylebox(state, "Button", style)
	theme.set_color("font_color", "Label", Color("f3e7cf"))
	theme.set_color("font_color", "Button", Color("f3e7cf"))
	theme.set_color("font_disabled_color", "Button", Color("84958d"))
	root.theme = theme
	layer.add_child(root)
	var panel := styled_panel(root, Vector2(18, 18), Vector2(320, 0))
	var column := panel_column(panel, 648)
	label_in(column, "TEZCATT / COFFEE", 24)
	stats = label_in(column, "", 18)
	status_clock = label_in(column, "Doors open at 8:00 AM", 16)
	price = SpinBox.new()
	price.min_value = 0.5
	price.max_value = 12
	price.step = 0.25
	price.value = 3
	price.prefix = "Coffee $"
	price.custom_minimum_size.y = 44
	column.add_child(price)
	stock_button = button(column, "100 beans • $10", buy_stock)
	ad_button = button(column, "Local advertising • $5", buy_ad)
	open_button = button(column, "OPEN CAFÉ", open_day)
	pause_button = button(column, "Pause", toggle_pause)
	investment_button = button(column, "Investment desk • locked", toggle_investments)
	button(column, "Tutorial / help", show_tutorial)
	message = label_in(column, "A new café. A fresh start.\nChoose a fair price and welcome your neighbors.", 16)
	story_label = label_in(column, "", 16)
	upgrade_panel = styled_panel(root, Vector2(858, 18), Vector2(400, 0))
	var investments := panel_column(upgrade_panel, 648)
	label_in(investments, "YOUR INVESTMENT DESK", 24)
	ledger_label = label_in(investments, "", 17)
	label_in(investments, "Stock using earned profits\n12 pastries: $18 → $3.50 each\n12 iced coffees: $15 → $4 each\n4 merchandise items: $25 → $10 each", 16)
	pastry_button = button(investments, "Add pastries • $18", buy_pastries)
	iced_button = button(investments, "Add iced coffee • $15", buy_iced)
	merch_button = button(investments, "Add merchandise • $25", buy_merch)
	repair_button = button(investments, "Repair equipment", repair_equipment)
	replace_espresso = button(investments, "Replace espresso machine • $80", replace_machine.bind("espresso"))
	replace_oven = button(investments, "Replace oven • $65", replace_machine.bind("oven"))
	label_in(investments, "A repair reserve protects tomorrow's sales. Replacement reduces future failure risk.\n1 game hour = 6 seconds. Paid repairs take 1–2 hours.", 16)
	button(investments, "Close desk", toggle_investments)
	upgrade_panel.hide()
	# Setup is a separate entrance with a live 3D character preview.
	setup_panel = styled_panel(root, Vector2(350, 35), Vector2(565, 0))
	var setup := panel_column(setup_panel, 600)
	label_in(setup, "WELCOME TO YOUR CAFÉ", 28)
	label_in(setup, "Make a home for your neighborhood. Start with coffee, learn the books, and grow one good decision at a time.")
	setup_name = LineEdit.new()
	label_in(setup, "Your name", 16)
	setup_name.placeholder_text = "Your name"
	setup_name.max_length = 24
	setup_name.custom_minimum_size.y = 44
	setup.add_child(setup_name)
	setup_gender = OptionButton.new()
	label_in(setup, "Gender • any appearance is available to everyone", 16)
	for value in ["Woman", "Man", "Nonbinary", "Prefer not to say"]: setup_gender.add_item(value)
	setup_gender.select(3)
	setup.add_child(setup_gender)
	setup_style = OptionButton.new()
	label_in(setup, "Choose your character", 16)
	for value in ["Cedar • copper apron", "Sage • teal apron", "Nova • blue cap", "Sunny • gold apron"]: setup_style.add_item(value)
	setup_style.item_selected.connect(update_setup_preview)
	setup.add_child(setup_style)
	setup_skin = OptionButton.new()
	label_in(setup, "Choose a skin tone", 16)
	for value in ["Skin tone 1", "Skin tone 2", "Skin tone 3", "Skin tone 4"]: setup_skin.add_item(value)
	setup_skin.item_selected.connect(update_setup_preview)
	setup.add_child(setup_skin)
	var viewport_container := SubViewportContainer.new()
	viewport_container.custom_minimum_size = Vector2(490, 200)
	viewport_container.stretch = true
	setup.add_child(viewport_container)
	var viewport := SubViewport.new()
	viewport.size = Vector2i(490, 200)
	viewport.own_world_3d = true
	viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	viewport_container.add_child(viewport)
	setup_preview = Node3D.new()
	viewport.add_child(setup_preview)
	var camera := Camera3D.new()
	setup_preview.add_child(camera)
	camera.position = Vector3(0, 1.1, 3.6)
	camera.look_at(Vector3(0, 1.0, 0))
	camera.current = true
	var light := DirectionalLight3D.new()
	light.rotation_degrees = Vector3(-30, -30, 0)
	setup_preview.add_child(light)
	update_setup_preview()
	button(setup, "Begin my story", accept_setup)
	setup_panel.hide()
	tutorial_panel = styled_panel(root, Vector2(350, 170), Vector2(560, 0))
	var tutorial := panel_column(tutorial_panel)
	label_in(tutorial, "YOUR FIRST DAY / TUTORIAL", 24)
	tutorial_label = label_in(tutorial, "", 20)
	tutorial_label.custom_minimum_size = Vector2(500, 180)
	tutorial_button = button(tutorial, "Next", advance_tutorial)
	tutorial_panel.hide()

func update_setup_preview(_index: int = 0) -> void:
	if setup_preview == null: return
	for child in setup_preview.get_children():
		if child.name == "Avatar":
			setup_preview.remove_child(child)
			child.queue_free()
	var avatar := character_model(setup_style.selected, setup_skin.selected)
	avatar.name = "Avatar"
	setup_preview.add_child(avatar)

func show_setup() -> void:
	setup_panel.show()
	refresh()

func accept_setup() -> void:
	var selected_name := setup_name.text.strip_edges()
	if selected_name.is_empty():
		setup_name.placeholder_text = "Please enter your name to begin"
		return
	economy.player_name = selected_name
	economy.gender = setup_gender.get_item_text(setup_gender.selected)
	economy.character = setup_style.selected
	economy.skin = setup_skin.selected
	setup_panel.hide()
	build_player()
	checkpoint()
	show_tutorial()

func show_tutorial() -> void:
	if setup_panel.visible: return
	if running and not paused: toggle_pause()
	tutorial_step = 0
	tutorial_panel.show()
	update_tutorial()
	refresh()

func update_tutorial() -> void:
	var pages := [
		"1 / 4 • Welcome, %s!\nYou begin with $1,000 and 100 beans. Set a coffee price, then open the café. Low prices attract buyers; high prices can lose sales." % economy.player_name,
		"2 / 4 • Read your books\nRevenue is not profit. Beans, advertising, serving costs and repairs all count as expenses. Your day-end ledger shows the difference.",
		"3 / 4 • Reinvest carefully\nAfter your first profitable day, a second panel unlocks pastries, iced coffee and merchandise. Spend earned profits and keep at least $60 for emergency repairs.",
		"4 / 4 • Plan for the seasons\nSeasons change every seven days. Warm days favor iced drinks, cold days favor coffee. Later levels bring breakdowns. Pay for a 1–2 hour repair or invest in reliable replacements."
	]
	tutorial_label.text = pages[tutorial_step]
	tutorial_button.text = "Start serving" if tutorial_step == 3 else "Next"

func advance_tutorial() -> void:
	tutorial_step += 1
	if tutorial_step >= 4:
		economy.tutorial_done = true
		tutorial_panel.hide()
		checkpoint()
		refresh()
	else: update_tutorial()

func checkpoint() -> void:
	if economy.save_game() != OK:
		message.text = "Save failed. Keep the app open and check available storage."

func refresh() -> void:
	if stats == null: return
	var name_text := economy.player_name if not economy.player_name.is_empty() else "Your café"
	stats.text = "%s • LEVEL %d\nDAY %d / %s\n%d°F / %.1f°C\nCash $%.2f • Beans %d\nPastries %d / Iced %d / Merch %d" % [name_text, economy.level(), economy.day, Economy.SEASONS[economy.season], economy.temperature_f, (economy.temperature_f - 32) / 1.8, economy.cash / 100.0, economy.beans, economy.pastries, economy.iced_coffees, economy.merch]
	var modal := setup_panel.visible or tutorial_panel.visible
	stock_button.disabled = running or modal or economy.cash < 1000
	ad_button.disabled = running or modal or economy.cash < 500
	open_button.disabled = running or modal
	price.editable = not running and not modal
	pause_button.disabled = not running or modal
	investment_button.disabled = modal or (not economy.expansion_unlocked and economy.machine_broken.is_empty())
	investment_button.text = "Investment desk" if economy.expansion_unlocked else ("Equipment repairs" if not economy.machine_broken.is_empty() else "Investment desk • earn profit")
	story_label.text = economy.story()
	var window_color: Color = [Color("c2dbe6"), Color("a9d5b0"), Color("92d3e2"), Color("d4ae79")][economy.season]
	for window in seasonal_windows:
		var window_material: StandardMaterial3D = window.material_override
		window_material.albedo_color = window_color
	var available := maxi(0, economy.profit_earned - economy.investment_spent)
	var budget := mini(available, economy.cash)
	pastry_button.disabled = running or budget < 1800 or not economy.expansion_unlocked
	iced_button.disabled = running or budget < 1500 or not economy.expansion_unlocked
	merch_button.disabled = running or budget < 2500 or not economy.expansion_unlocked
	replace_espresso.disabled = running or budget < 8000 or not economy.expansion_unlocked
	replace_oven.disabled = running or budget < 6500 or not economy.expansion_unlocked
	repair_button.disabled = economy.machine_broken.is_empty() or economy.repair_remaining > 0 or economy.cash < economy.repair_cost()
	if economy.machine_broken.is_empty(): repair_button.text = "Equipment healthy"
	elif economy.repair_remaining > 0: repair_button.text = "Repair in progress • %.1f hours" % (economy.repair_remaining / 6)
	else: repair_button.text = "Repair %s • $%.2f" % [economy.machine_broken, economy.repair_cost() / 100.0]
	ledger_label.text = "Last day\nRevenue $%.2f / Expenses $%.2f\nNET PROFIT $%.2f\n\nUnspent earned profits $%.2f\nCash available $%.2f\nEspresso tier %d / Oven tier %d\n%s" % [economy.last_revenue / 100.0, economy.last_expenses / 100.0, economy.last_profit / 100.0, available / 100.0, economy.cash / 100.0, economy.espresso_level, economy.oven_level, "Reserve warning: cash below $60." if economy.cash < Economy.RESERVE else "Repair reserve covered: $60."]
	status_clock.text = "OPEN • %02d:%02d / %d customers left" % [8 + int(elapsed / 6), int(fmod(elapsed, 6) * 10), remaining] if running else "Ready for the next day"

func toggle_investments() -> void:
	upgrade_panel.visible = not upgrade_panel.visible

func buy_stock() -> void:
	if not running and economy.purchase(1000, 100):
		checkpoint()
		refresh()

func buy_ad() -> void:
	if not running and economy.purchase(500, 0):
		economy.advertising += 5
		message.text = "Advertising booked. Its cost appears in your next day's ledger."
		checkpoint()
		refresh()

func buy_pastries() -> void: buy_product("pastry")
func buy_iced() -> void: buy_product("iced")
func buy_merch() -> void: buy_product("merch")

func buy_product(kind: String) -> void:
	if economy.add_product(kind, Economy.PRODUCT_COST[kind]):
		message.text = "New stock ready. Keep some cash for unexpected repairs."
		checkpoint()
		update_products()
		refresh()

func replace_machine(kind: String) -> void:
	if economy.replace_machine(kind):
		message.text = "New %s installed. Higher reliability reduces future breakdown risk." % kind
		checkpoint()
		refresh()

func repair_equipment() -> void:
	if economy.repair_machine(economy.machine_broken, economy.repair_cost()):
		message.text = "Technician booked. Repairs complete in %d game hours." % economy.broken_hours if running else "Equipment repaired before opening."
		checkpoint()
		refresh()

func update_products() -> void:
	for child in product_display.get_children():
		product_display.remove_child(child)
		child.queue_free()
	if economy.pastries > 0:
		box(product_display, Vector3(1.1, 0.12, 0.55), Vector3(0.1, 1.5, -2), Color("d7b887"))
		for x in [-0.25, 0.1, 0.45]:
			sphere(product_display, 0.12, Vector3(x, 1.63, -2), Color("d69a55"))
	if economy.iced_coffees > 0:
		for x in [0.85, 1.15]:
			cylinder(product_display, 0.13, 0.3, Vector3(x, 1.6, -2), Color("a7dadb"))
			cylinder(product_display, 0.014, 0.25, Vector3(x, 1.84, -2), Color("c27758"))
	if economy.merch > 0:
		for x in [3.3, 3.7]:
			cylinder(product_display, 0.15, 0.27, Vector3(x, 1.6, -2), Color("e7d4a5"))

func open_day() -> void:
	if running or setup_panel.visible or tutorial_panel.visible: return
	running = true
	paused = false
	pause_button.text = "Pause"
	economy.begin_day()
	remaining = clampi(16 + economy.level() * 2 + int(economy.advertising / 5), 16, 36)
	day_duration = maxf(60, remaining * 2.0)
	cups_today = 0
	elapsed = 0
	arrival = 0
	failure_checked = false
	upgrade_panel.hide()
	message.text = "Doors open. Welcome your neighbors!"
	checkpoint()
	update_products()
	refresh()

func toggle_pause() -> void:
	if not running: return
	paused = not paused
	pause_button.text = "Resume" if paused else "Pause"

func spawn_customer() -> void:
	var person := character_model(economy.rng.randi_range(0, 3), economy.rng.randi_range(0, 3))
	add_child(person)
	person.position = Vector3(5, 0, 4)
	person.set_meta("age", 0.0)
	person.set_meta("served", false)
	customers.append(person)

func _process(delta: float) -> void:
	if paused or not running: return
	elapsed += delta
	arrival -= delta
	if economy.tick_repair(delta):
		message.text = "Repair complete. Service is back!"
		checkpoint()
	if not failure_checked and elapsed >= day_duration * 0.35:
		failure_checked = true
		if economy.level() >= 2 and economy.machine_broken.is_empty():
			var kind := "oven" if economy.pastries > 0 and economy.rng.randf() < 0.4 else "espresso"
			var tier: int = economy.oven_level if kind == "oven" else economy.espresso_level
			var risk := minf(0.55, 0.12 + economy.level() * 0.04) / tier
			if economy.rng.randf() < risk:
				economy.breakdown(kind, economy.rng.randi_range(1, 2))
				message.text = "%s broke during the rush! Open the investment desk to pay for repairs." % kind.capitalize()
				upgrade_panel.show()
				checkpoint()
	if remaining > 0 and arrival <= 0:
		spawn_customer()
		remaining -= 1
		arrival = day_duration / (16 + economy.level() * 2)
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
			serve_customer()
			person.set_meta("served", true)
			checkpoint()
			update_products()
		else:
			customers.erase(person)
			person.queue_free()
	refresh()
	if remaining == 0 and customers.is_empty():
		finish_day()

func serve_customer() -> void:
	var bought := false
	var chance := clampf(0.8 - maxf(0, economy.temperature_f - 60) / 160.0 + economy.advertising / 200.0, 0.3, 0.95)
	chance *= minf(1, 3.0 / price.value)
	if economy.rng.randf() < chance:
		var count := economy.serve(1 + int(price.value <= 2), int(round(price.value * 100)))
		cups_today += count
		bought = count > 0
	if economy.rng.randf() < 0.45 and economy.sell_product("pastry"): bought = true
	var iced_demand := clampf((economy.temperature_f - 40) / 70.0, 0.1, 0.85)
	if economy.rng.randf() < iced_demand and economy.sell_product("iced"): bought = true
	if economy.rng.randf() < 0.16 and economy.sell_product("merch"): bought = true
	if economy.machine_broken == "espresso":
		message.text = "Coffee service is down. Iced drinks and merchandise can still earn sales."
	elif not bought: message.text = "A visitor browsed the menu. Review your price and available stock."
	else: message.text = "Another neighbor served. Today's revenue: $%.2f" % (economy.day_revenue / 100.0)

func finish_day() -> void:
	running = false
	economy.finish_day()
	message.text = "DAY COMPLETE • %d coffees\nRevenue $%.2f • Expenses $%.2f\nNET PROFIT $%.2f" % [cups_today, economy.last_revenue / 100.0, economy.last_expenses / 100.0, economy.last_profit / 100.0]
	if economy.last_profit <= 0: message.text += "\nReduce unnecessary spending and review your prices."
	upgrade_panel.visible = economy.expansion_unlocked or not economy.machine_broken.is_empty()
	checkpoint()
	refresh()

func _notification(what: int) -> void:
	if what == NOTIFICATION_APPLICATION_PAUSED and running and not paused:
		toggle_pause()
