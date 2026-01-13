extends Control

@onready var buttons := $Panel/VBoxContainer.get_children()

func _ready():
	hide()
	process_mode = Node.PROCESS_MODE_ALWAYS

func _input(event):
	if event.is_action_pressed("ui_pause"):
		toggle_pause()
	if get_tree().paused and event.is_action_pressed("ui_cancel"):
		toggle_pause()

func toggle_pause():
	get_tree().paused = !get_tree().paused
	visible = get_tree().paused
	if visible:
		buttons[0].grab_focus()

func _on_continue_pressed():
	toggle_pause()

func _on_restart_pressed():
	get_tree().paused = false
	get_tree().reload_current_scene()

func _on_exit_pressed():
	get_tree().quit()
