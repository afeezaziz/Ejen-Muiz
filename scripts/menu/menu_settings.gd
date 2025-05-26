# SettingsMenu.gd
extends Control

signal back_pressed

# Connect the BackButton's "pressed" signal to _on_back_button_pressed
# using the editor's Node->Signals tab, similar to MainMenu.

# If you connect in code:
# func _ready():
# 	$SettingsVBox/BackButton.connect("pressed", Callable(self, "_on_back_button_pressed"))


func _on_button_pressed() -> void:
	emit_signal("back_pressed")
