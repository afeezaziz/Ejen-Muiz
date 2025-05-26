# Main.gd
extends Control # Or Node2D if you used that as the root for Main.tscn

# Preload the scenes we want to switch between.
# Using "PackedScene" type hint is good practice.
const MainMenuScene: PackedScene = preload("res://scenes/menu/main.tscn")
const SettingsMenuScene: PackedScene = preload("res://scenes/menu/settings.tscn")

var current_panel: Control # To hold a reference to the currently active UI panel

func _ready():
	# Set a default clear color (optional, can also be done in project settings)
	# DisplayServer.window_set_default_clear_color(Color(0.1, 0.1, 0.15))

	# Start by showing the main menu
	show_main_menu()

func _clear_current_panel():
	if is_instance_valid(current_panel):
		current_panel.queue_free() # Remove and free the old panel
		current_panel = null

func show_main_menu():
	_clear_current_panel()

	var main_menu_instance = MainMenuScene.instantiate()
	add_child(main_menu_instance)
	current_panel = main_menu_instance # Keep track of it

	# Connect to signals emitted by the MainMenu instance's script
	# The script attached to MainMenuScene's root node should define these signals
	main_menu_instance.connect("play_pressed", Callable(self, "_on_MainMenu_play_pressed"))
	main_menu_instance.connect("settings_pressed", Callable(self, "_on_MainMenu_settings_pressed"))
	main_menu_instance.connect("quit_pressed", Callable(self, "_on_MainMenu_quit_pressed"))

func show_settings_menu():
	_clear_current_panel()

	var settings_menu_instance = SettingsMenuScene.instantiate()
	add_child(settings_menu_instance)
	current_panel = settings_menu_instance

	# Connect to signals from the SettingsMenu instance
	settings_menu_instance.connect("back_pressed", Callable(self, "_on_SettingsMenu_back_pressed"))

# --- Signal Handlers from UI Panels ---

func _on_MainMenu_play_pressed():
	print("Play button pressed! (from Main.gd)")
	# Here you would transition to your actual game scene or start game logic
	# For now, let's just show a temporary message:
	_clear_current_panel()
	var play_label = Label.new()
	play_label.text = "Game Would Start Now!"
	play_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	play_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	play_label.set_anchors_preset(Control.PRESET_FULL_RECT) # Make it fill the screen
	add_child(play_label)
	current_panel = play_label # So it can be cleared
	# Optional: Timer to go back to main menu automatically
	# get_tree().create_timer(3.0).connect("timeout", Callable(self, "show_main_menu"))


func _on_MainMenu_settings_pressed():
	print("Settings button pressed. Transitioning to settings. (from Main.gd)")
	show_settings_menu()

func _on_MainMenu_quit_pressed():
	print("Quit button pressed. Exiting. (from Main.gd)")
	get_tree().quit()

func _on_SettingsMenu_back_pressed():
	print("Back button pressed in Settings. Transitioning to main menu. (from Main.gd)")
	show_main_menu()
