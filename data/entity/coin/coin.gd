extends Area2D

@onready var animation_player = $AnimationPlayer
@onready var timer = $Timer

func _on_body_entered(_body: Node2D) -> void:
	print("+1 Coin!")
	animation_player.play("collect", -1, 1.0, false)
	timer.start()


func _on_timer_timeout() -> void:
	queue_free()
