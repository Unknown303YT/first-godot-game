extends CharacterBody2D

const SPEED = 100.0
const JUMP_VELOCITY = -300
const WALL_REBOUND = 100
const MAX_REBOUNDS_GRACE = 0.25
const MAX_GROUND_SLAM_JUMP_TIME = 1
const GROUND_SLAM_JUMP_MODIFIER: Vector2 = Vector2(-100, -100)
const WALL_SLIDE_MULTIPLIER = 0.75
const DEFAULT_GRAVITY: Vector2 = Vector2(0, 980)
const FALL_ACCELERATION = 1.25

var facing = 1
var rebounds_grace = MAX_REBOUNDS_GRACE
var ground_slam_jump_timer_start = false
var can_ground_slam_jump = false
var ground_slam_jump_time = MAX_GROUND_SLAM_JUMP_TIME
var gravity: Vector2 = DEFAULT_GRAVITY
var prevGravity: Vector2 = gravity

var prevVelocity: Vector2
var lastPrinted

@onready var kill_area: Area2D = $"../KillArea"
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

func _physics_process(delta: float) -> void:
	rebounds_grace -= delta
	if can_ground_slam_jump:
		ground_slam_jump_time -= delta
	
	# Add the gravity.
	if not is_on_floor():
		if velocity.y > 0:
			if is_on_wall():
				gravity.y += FALL_ACCELERATION * WALL_SLIDE_MULTIPLIER
			else:
				gravity.y += FALL_ACCELERATION
		velocity += gravity * delta
	else:
		gravity = DEFAULT_GRAVITY
	
	#if gravity == DEFAULT_GRAVITY:
		#if not prevGravity == DEFAULT_GRAVITY:
			#print("=============GRAVITY RESET=============")
	#else:
		#if gravity.y + 1 > prevGravity.y:
			#print("GRAVITY: " + str(round(gravity)))
		#elif gravity.y - 1 < prevGravity.y:
			#print("GRAVITY: " + str(round(gravity)))
	#
	#var printed
	#if velocity.y == 0:
		#if not(lastPrinted == printed):
			#print("=============VELOCITY RESET=============")
	#else:
		#printed = "VELOCITY: " + str(round(velocity))
		#if velocity.y + 1 > prevVelocity.y:
			#print(printed)
		#elif velocity.y - 1 < prevVelocity.y:
			#print(printed)
			#
	#prevGravity = gravity
	#prevVelocity = velocity
	#lastPrinted = printed

	# Get the input direction. -1 = Left, 0 = Still, 1 = Right 
	var direction := Input.get_axis("move_left", "move_right")
	
	if direction > 0:
		facing = 1
	elif direction < 0:
		facing = 0
	
	# Handle sprite direction
	if is_on_floor():
		if direction > 0:
			animated_sprite.flip_h = false
		elif direction < 0:
			animated_sprite.flip_h = true
		
		rebounds_grace = 0
	
	# Play animations
	if is_on_floor():
		if direction == 0:
			animated_sprite.play("idle")
		else:
			animated_sprite.play("run")
	else:
		animated_sprite.play("jump")

	# Handle jump.
	if Input.is_action_just_pressed("jump"):
		if is_on_floor():
			velocity.y = JUMP_VELOCITY
			if (canGroundSlamJump()):
				velocity += GROUND_SLAM_JUMP_MODIFIER
				can_ground_slam_jump = false
		if is_on_wall():
			if not is_on_floor():
				velocity.y = JUMP_VELOCITY - 50
			else:
				velocity.y = JUMP_VELOCITY
	
	if not is_on_floor():
		if Input.is_action_just_pressed("slam"):
			velocity.y = -JUMP_VELOCITY + 50
			ground_slam_jump_timer_start = false
	else:
		if ground_slam_jump_timer_start:
			can_ground_slam_jump = true
			ground_slam_jump_time = MAX_GROUND_SLAM_JUMP_TIME
			ground_slam_jump_timer_start = false
	
	handleMovement(direction)
	
	if is_on_wall() and not is_on_floor():
		if Input.is_action_just_pressed("jump"):
			if animated_sprite.flip_h:
				velocity.x = WALL_REBOUND
			else:
				velocity.x = -WALL_REBOUND
			velocity.y = JUMP_VELOCITY
			animated_sprite.flip_h = not(animated_sprite.flip_h)
			rebounds_grace = MAX_REBOUNDS_GRACE
		else:
			velocity.y *= WALL_SLIDE_MULTIPLIER
		move_and_collide(velocity * delta)

func handleMovement(direction: float):
	# Handle movement
	if not kill_area.isDying():
		if rebounds_grace <= 0:
			if direction:
				velocity.x = direction * SPEED
			else:
				velocity.x = move_toward(velocity.x, 0, SPEED)
		else:
			if direction == -1 and facing == 0:
				velocity.x = move_toward(velocity.x, 0, SPEED)
			if direction == 1 and facing == 1:
				direction * SPEED
		#else:
			#if direction > facing or direction < facing:
				#if direction:
					#velocity.x = direction * SPEED
				#else:
					#velocity.x = move_toward(velocity.x, 0, SPEED)
			#else:
				#print(direction)
				
	else:
		velocity.x = 0

	move_and_slide()

func canGroundSlamJump() -> bool:
	if ground_slam_jump_time >= 0 and can_ground_slam_jump:
		return true
	else:
		return false
