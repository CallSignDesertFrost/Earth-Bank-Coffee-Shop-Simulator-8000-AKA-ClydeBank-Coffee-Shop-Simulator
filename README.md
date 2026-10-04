# TEZCATT Coffee Shop — 3D Android adaptation

Open `game/project.godot` in Godot 4.5.1 and press F5 to play. First launch opens name, gender, character and skin-tone selection with a live 3D preview, followed by a four-step tutorial. Build a neighborhood café through five story chapters: earn a profitable day, diversify the menu, replace unreliable equipment and grow a resilient cash reserve.

After the first profitable day, a separate investment panel unlocks pastries, iced coffee and merchandise. Seasons change every seven game days and show both Fahrenheit and Celsius. Later levels introduce espresso/oven breakdowns during service; paid repairs take one or two game hours, while replacement reduces failure risk. Rounded characters, faces, shoes, café lighting, windows and stocked product displays extend the original scene. See [gameplay details](docs/GAMEPLAY.md).

The local save checkpoints profile choices, purchases, advertising, customer transactions, equipment faults and repair booking. An interrupted day closes on next launch with its completed sales and costs retained. Pause/backgrounding freezes the simulation. All money uses integer cents.

The new implementation adapts the repository's weather, advertising, inventory, pricing and daily sales concepts. Prices now affect purchase probability and running out of stock closes sales rather than permanently ending the game. Customer phone/email data is not imported. Original Python files are retained unchanged for reference.

## Languages
Godot's rendering engine is C++. Gameplay/UI use GDScript; original prototype uses Python. There is no separate “C+” language. A custom C++ extension is unnecessary for this small simulation and is not included.

## Validation
```
godot --headless --path game --script res://scripts/test_game.gd
godot --headless --path game --quit-after 120
```
Tests cover investment unlocks and budgets, ledger accounting, unaffected product sales during failures, timed repairs, replacement, seasonal bounds and conversion, profile/tutorial flow, save validation, a complete animated day, pause, and interrupted-day recovery. They use separate save paths. Headless tests and startup pass; rendered visual QA and Android device/export performance remain unverified.

See [Android release preparation](docs/ANDROID_RELEASE.md). This is a playable first 3D adaptation, not a signed or store-approved release.
