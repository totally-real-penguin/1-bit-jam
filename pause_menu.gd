extends CanvasLayer

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed('pause'):
		get_tree().paused = !get_tree().paused
		$Pause.visible = !$Pause.visible
		$Pause/OptionsPanel.visible = false

func _on_continue_pressed() -> void:
	get_tree().paused = !get_tree().paused
	$Pause.visible = !$Pause.visible
	$Pause/OptionsPanel.visible = false

func _on_options_pressed() -> void:
	$Pause/OptionsPanel.visible = true


func _on_exit_pressed() -> void:
	get_tree().quit()

func _on_back_pressed() -> void:
	$Pause/OptionsPanel.visible = false
