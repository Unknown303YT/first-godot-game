extends CharacterBody2D

# Constants
const SPEED = 100.0
const JUMP_VELOCITY = -300.0
const WALL_REBOUND = 100
const WALL_SLIDE_MULTIPLIER = 0.999
const GRAVITY = 980.0
const FALL_ACCELERATION = 15.0
const SLAM_SPEED = 700.0
const REBOUND_GRACE_TIME = 0.25
const HIGH_JUMP_WINDOW = 1  # Time (seconds) to jump after slamming for high jump

# Variables
var gravity = GRAVITY
var facing = 1
var rebounds_grace = 0.0
var can_high_jump = false
var high_jump_timer = 0.0

# Nodes
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var kill_area: Area2D = $"../KillArea"

func _physics_process(delta: float) -> void:
	# Update timers
	rebounds_grace -= delta
	if can_high_jump:
		high_jump_timer -= delta
		if high_jump_timer <= 0:
			can_high_jump = false  # Disable high jump after 0.5s

	# Apply Gravity Acceleration when falling (not rising)
	if velocity.y > 0:
		velocity.y += FALL_ACCELERATION * delta
	elif not is_on_floor():
		velocity.y += gravity * delta

	# Handle movement input (disabled during rebound grace)
	var direction = 0 if rebounds_grace > 0 else Input.get_axis("move_left", "move_right")

	# Prevent movement if kill_area.isDying() is true
	if kill_area.isDying():
		velocity.x = 0
	else:
		if direction != 0:
			facing = 1 if direction > 0 else -1
			velocity.x = direction * SPEED
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)

	# Handle Jumping
	if Input.is_action_just_pressed("jump"):
		if is_on_floor():
			velocity.y = JUMP_VELOCITY
			if can_high_jump:
				velocity.y *= 1.2  # Higher jump power after slamming
				can_high_jump = false  # Reset high jump flag

		elif is_on_wall() and not is_on_floor():
			# Wall Jump - Apply Rebound and Grace Timer
			velocity.y = JUMP_VELOCITY
			velocity.x = WALL_REBOUND * (-facing)  # Push off the wall
			rebounds_grace = REBOUND_GRACE_TIME  # Prevent accidental cancelling

	# Handle Ground Slam
	if Input.is_action_just_pressed("slam") and not is_on_floor():
		velocity.x = 0  # Cancel X-axis movement
		velocity.y = SLAM_SPEED  # Fast slam down
		can_high_jump = true  # Enable high jump
		high_jump_timer = HIGH_JUMP_WINDOW  # Start 0.5s timer

	# Wall Sliding - Slow Descent on Walls
	if is_on_wall() and not is_on_floor():
		velocity.y *= WALL_SLIDE_MULTIPLIER
	elif not is_on_floor():
		velocity.y += FALL_ACCELERATION
	
	if (Input.is_action_just_pressed("jump")):
		velocity.y = JUMP_VELOCITY
	
	move_and_slide()

	# Update animations
	update_animations(direction)

func update_animations(direction: float) -> void:
	animated_sprite.flip_h = facing == -1  # Flip sprite based on facing direction
	
	if is_on_floor():
		if velocity.x == 0:
			animated_sprite.play("idle")
		else:
			animated_sprite.play("run")
	else:
		animated_sprite.play("jump")
