extends StaticBody2D

var can_destroy:bool = true

func destroy():
	if can_destroy == true:
		$Break.start()
		can_destroy = false

func _on_respawn_timeout() -> void:
	$Collision.disabled = false
	$Sprite.frame = 0
	can_destroy = true

func _on_break_timeout() -> void:
	$Collision.disabled = true
	$Sprite.frame = 1
	$Respawn.start()

func _on_player_detector_body_entered(body: Node2D) -> void:
	print(body.name)
