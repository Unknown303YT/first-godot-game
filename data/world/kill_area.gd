extends Area2D

@onready var anim_timer: Timer = $AnimTimer
@onready var timer: Timer = $Timer
@onready var animated_sprite: AnimatedSprite2D = get_parent().get_node("Player/AnimatedSprite2D")
@onready var death: AnimationPlayer = get_parent().get_node("Player/AnimationPlayer")
var player_body: Node2D = null

var is_dying = false
var is_still_dying = false

func _on_body_entered(body: Node2D) -> void:
	is_dying = true
	is_still_dying = true
	print("K.O.")
	Engine.time_scale = 0.6
	animated_sprite.flip_v = true
	player_body = body
	death.play("die", -1, 1.0, false)
	anim_timer.start()

func _on_timer_timeout() -> void:
	Engine.time_scale = 1.0
	get_tree().reload_current_scene()


func _on_anim_timer_timeout() -> void:
	is_still_dying = false
	if not(player_body == null):
		player_body.get_node("CollisionShape2D").queue_free()
	timer.start()

func isDying() -> bool:
	return is_dying
