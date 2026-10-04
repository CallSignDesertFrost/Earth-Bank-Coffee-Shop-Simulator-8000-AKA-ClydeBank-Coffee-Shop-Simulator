# TEZCATT Coffee Shop — 3D Android adaptation

Open `game/project.godot` in Godot 4.5.1 and press F6/F5 to play. Landscape, offline café management with original procedural 3D furniture and walking customers. Set a price, buy beans, advertise, open the café, and review the day. Pause freezes simulation; backgrounding pauses it automatically. All money uses integer cents. Saves are local and written at completed days and inventory purchases. An interrupted day restarts from the last checkpoint. Advertising is session-only until the day completes.

The new implementation adapts the repository's weather, advertising, inventory, pricing and daily sales concepts. Prices now affect purchase probability and running out of stock closes sales rather than permanently ending the game. Customer phone/email data is not imported. Original Python files are retained unchanged for reference.

## Languages
Godot's rendering engine is C++. Gameplay/UI use GDScript; original prototype uses Python. There is no separate “C+” language. A custom C++ extension is unnecessary for this small simulation and is not included.

## Validation
```
godot --headless --path game --script res://scripts/test_game.gd
godot --headless --path game --quit-after 120
```
Tests cover purchase rejection, cent accounting, stock limits, save round-trip, malformed saves, and a full animated day. They use separate save paths. Android export and visual/device performance are not yet validated.

See [Android release preparation](docs/ANDROID_RELEASE.md). This is a playable first 3D adaptation, not a signed or store-approved release.
