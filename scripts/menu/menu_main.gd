# MainMenu.gd
extends Control

# Define signals that this UI panel can emit
signal play_pressed
signal settings_pressed
signal quit_pressed

# We don't strictly need _ready() if all connections are done in editor
# But it's good practice to get node references if you need them for more complex logic.
# For button connections, we can use the editor's signal connection feature.

# --- How to connect buttons using the editor (recommended for .tscn scenes) ---
# 1. Select PlayButton in the Scene dock.
# 2. Go to the "Node" tab (next to Inspector).
# 3. Under "Signals", double-click the "pressed()" signal.
# 4. A "Connect Signal" dialog will appear.
# 5. Make sure "Pick" is selected for the "Receiver Method".
# 6. The "Connect to Node" should be your MainMenu root node.
# 7. It will suggest a method name like "_on_play_button_pressed". Click "Connect".
# 8. Repeat for SettingsButton and QuitButton.

# Godot will automatically create these functions in this script:

func _on_play_button_pressed():
	emit_signal("play_pressed")

func _on_settings_button_pressed():
	emit_signal("settings_pressed")

func _on_quit_button_pressed():
	emit_signal("quit_pressed")

# If you prefer to connect in code (alternative to editor connections):
# func _ready():
# 	$MenuVBox/PlayButton.connect("pressed", Callable(self, "_on_play_button_pressed"))
# 	$MenuVBox/SettingsButton.connect("pressed", Callable(self, "_on_settings_button_pressed"))
# 	$MenuVBox/QuitButton.connect("pressed", Callable(self, "_on_quit_button_pressed"))
