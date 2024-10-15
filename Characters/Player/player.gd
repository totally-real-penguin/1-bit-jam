extends CharacterBody2D

const MaxSpeed = 280.0
const Acceleration = 800.0

const GroundDeceleration = 600
const AirDeceleration = 480

const JumpPower = -700
const MaxFallSpeed = 600
const FallAcceleration = 1100

const JumpEndEarlyGravityModifier = 3

const CoyoteTime = 0.15
const JumpBuffer = 0.2

var grounded: bool = true

var jump_to_consume: bool
var buffered_jump_usable: bool
var ended_jump_early: bool
var coyote_usable: bool

var move : Vector2

func handle_jump() -> void:
	move = Input.get_vector('left','right','up','down')

	if !ended_jump_early and !grounded and !Input.is_action_pressed('jump') and velocity.y < 0:
		ended_jump_early = true
	if !jump_to_consume and !buffered_jump_usable:
		return
	if grounded or coyote_usable:
		execute_jump()
	jump_to_consume = false

func execute_jump() -> void:
	if jump_to_consume == true:
		ended_jump_early = false
		buffered_jump_usable = false
		coyote_usable = false
		velocity.y = JumpPower
		print("jump")

func handle_direction(delta) -> void:
	if move.x == 0:
		var deceleration = GroundDeceleration if grounded else AirDeceleration
		velocity.x = move_toward(velocity.x,0,deceleration * delta)
	else:
		velocity.x = move_toward(velocity.x,move.x * MaxSpeed,Acceleration * delta)

func handle_gravity(delta):
	if grounded and velocity.y <= 0:
		velocity.y = 50
	else:
		var air_gravity = FallAcceleration
		if ended_jump_early and velocity.y > 0:
			air_gravity *= JumpEndEarlyGravityModifier
		velocity.y = move_toward(velocity.y,MaxFallSpeed,air_gravity * delta)

func _physics_process(delta: float) -> void:
	if !grounded and is_on_floor():
		coyote_usable = true
		buffered_jump_usable = true
		ended_jump_early = false
		grounded = true
	elif grounded and !is_on_floor():
		grounded = false

	if Input.is_action_just_pressed('jump'):
		jump_to_consume = true

	handle_direction(delta)
	handle_gravity(delta)
	handle_jump()

	move_and_slide()
