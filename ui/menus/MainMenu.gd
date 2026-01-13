extends Control

@onready var start_button := $CenterContainer/Panel/VBoxContainer/StartButton
@onready var settings_popup := $SettingsPopup

func _ready():
	start_button.grab_focus()

func _on_start_button_pressed():
	get_tree().change_scene_to_file("res://scenes/main/Main.tscn")

func _on_exit_button_pressed():
	get_tree().quit()
