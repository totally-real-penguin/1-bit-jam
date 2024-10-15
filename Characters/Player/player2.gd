extends CharacterBody2D

class StateMachine:
	enum PlayerStates {
		Idle,
		Run,
		Jump,
		Fall,
		FastFall,
	}
	var jump_ended_early:bool
	var is_in_wind: bool
	var state: PlayerStates
	func update_state(player:CharacterBody2D):

		if player.is_on_floor() and player.velocity.x == 0 and !is_in_wind:
			state = PlayerStates.Idle
		elif player.is_on_floor() and player.velocity.x != 0 or player.is_on_floor() and is_in_wind:
			state = PlayerStates.Run
		elif !player.is_on_floor() and player.velocity.y < 0 and !jump_ended_early and !is_in_wind:
			state = PlayerStates.Jump
		elif (!player.is_on_floor() and player.velocity.y > 0 and Input.is_action_pressed('down') and !is_in_wind) or (jump_ended_early and !is_in_wind):
			state = PlayerStates.FastFall
		elif !player.is_on_floor() and player.velocity.y > 0 and (state != PlayerStates.FastFall or is_in_wind):
			state = PlayerStates.Fall

const MaxSpeed = 180
const MaxAirSpeed = 140
const Acceleration = 500

var time = 0

const AirFriction = 200

var ground_friction = 400

const DefualtGroundFriction = 400

const MaxFallSpeed = 600
const JumpGravity = 310
const FallGravity = 360

const MaxFastFallSpeed = 800
const FastFallGravity = 450

const JumpPower = -260

const ApexModifier = 200

var can_use_apex: bool

var grace_time_active: bool

var state_machine = StateMachine.new()

var was_grounded: bool

var palette_index = 0

var friction_override: int

var wind_direction: Vector2i
var wind_speed: int

var max_speed = MaxSpeed
var acceleration  = Acceleration
var friction = ground_friction
var max_fall_speed = MaxFallSpeed
var gravity = FallGravity

var jump_buffer: bool

func palette_swap():
	if Input.is_action_just_pressed('swap_palette'):
		if palette_index == len(%ShaderOverlay.color_schemes.values())-1:
			palette_index = 0
		else:
			palette_index += 1
		%ShaderOverlay.update_colours(%ShaderOverlay.color_schemes.values()[palette_index])


func handle_sprite():
	match state_machine.state:
		0: # Idle
			$AnimationPlayer.play('Idle')
		1: # Run
			$AnimationPlayer.play('Run')
		2: # Jump
			$AnimationPlayer.play('Jump')
			gravity = JumpGravity
			friction = AirFriction
			max_speed = MaxAirSpeed
		3: # Fall
			$AnimationPlayer.play('Fall')
			friction = AirFriction
			max_speed = MaxAirSpeed
		4: # FastFall
			$AnimationPlayer.play('Fall')
			gravity = FastFallGravity
			max_fall_speed = MaxFastFallSpeed
			friction = AirFriction
			max_speed = MaxAirSpeed

func _physics_process(delta: float) -> void:
	var input_vector = Input.get_axis('left','right')

	gravity = FallGravity
	max_speed = MaxSpeed
	acceleration  = Acceleration
	friction = ground_friction
	max_fall_speed = MaxFallSpeed


	if input_vector < 0:
		$Sprite.flip_h = true
		$Sprite.offset.x = 0
	elif input_vector > 0:
		$Sprite.flip_h = false
		$Sprite.offset.x = -6

	if (is_on_floor() or grace_time_active) and (Input.is_action_just_pressed('jump') or jump_buffer):
		$AudioStreamPlayer.play()
		velocity.y = JumpPower

	if state_machine.state == 2 and !Input.is_action_pressed('jump') and state_machine.is_in_wind == false:
		state_machine.jump_ended_early = true
		velocity.y /= 1.5

	if is_on_floor():
		state_machine.jump_ended_early = false
		can_use_apex = true
	elif velocity.y > 0 and state_machine.state in [0,1] and !state_machine.is_in_wind:
		grace_time_active =  true
		$GraceTimer.start(0.1)

	if !is_on_floor() and Input.is_action_just_pressed('jump'):
		jump_buffer = true
		$AutoJumpTimer.start(0.15)

	state_machine.update_state(self)

	handle_sprite()

	if input_vector != 0 and (input_vector * velocity.x) >= 0 and wind_speed == 0:
		velocity.x = move_toward(velocity.x,max_speed * input_vector,(acceleration-friction) * delta)
	elif state_machine.is_in_wind:
		if wind_speed / -1 <= 0:
			velocity.x = move_toward(velocity.x,max_speed, (wind_direction.x) * delta)
		elif wind_speed / -1 >= 0:
			velocity.x = move_toward(velocity.x,-max_speed, (wind_direction.x) * delta)
		velocity.x = move_toward(velocity.x,max_speed * input_vector, (acceleration-friction) * delta)
	else:
		velocity.x = move_toward(velocity.x,0,friction*delta)
	velocity.y = move_toward(velocity.y,max_fall_speed,gravity * delta)

	if abs(velocity.y) <= 5 and !is_on_floor() and !state_machine.jump_ended_early and !state_machine.is_in_wind:
		velocity.x += ApexModifier * input_vector * delta
		can_use_apex = false

	velocity += Vector2(wind_direction) * delta

	palette_swap()
	set_height()
	move_and_slide()

func set_height() -> void:
	%Height.text = "Height: " + "%03d" % max(0,floor((384 - global_position.y)/32))

func _on_ground_check_body_shape_entered(body_rid: RID, body: Node2D, _body_shape_index: int, _local_shape_index: int) -> void:
	if body.get_parent().name == "TempPlatforms":
		body.destroy()
	if body.name == "Floor":
		var cell_data: TileData = body.get_cell_tile_data(body.get_coords_for_body_rid(body_rid))
		if cell_data.get_custom_data("friction") != 0:
			ground_friction = cell_data.get_custom_data("friction")
		else:
			ground_friction = DefualtGroundFriction

func _on_wind_check_area_entered(area: Area2D) -> void:
	if area.get_parent().name == "WindAreas":
		velocity.y = max(velocity.y,velocity.y/3)
		state_machine.is_in_wind = true
		wind_direction = area.get_meta("direction",Vector2.ZERO)
		wind_speed = area.get_meta("speed",0)
		var step = wind_speed / (abs(wind_direction.x) + abs(wind_direction.y))
		wind_direction.x = wind_direction.x * step
		wind_direction.y = wind_direction.y * step
	elif area.name == "Win":
		get_tree().change_scene_to_file('res://Levels/End.tscn')

func _on_wind_check_area_exited(area: Area2D) -> void:
	if area.get_parent().name == "WindAreas":
		velocity.y = min(velocity.y,velocity.y/1.5)
		wind_direction = Vector2i.ZERO
		wind_speed = 0
		state_machine.is_in_wind = false

func _on_timer_timeout() -> void:
	time += 1
	var h = floor(time/3600)
	var m = floor((time-(h*3600))/60)
	var s = time%60
	%TimeDisplay.text = "%02d:%02d:%02d" % [h,m,s]


func _on_auto_jump_timer_timeout() -> void:
	jump_buffer = false

func _on_grace_timer_timeout() -> void:
	grace_time_active = false


func _on_option_button_item_selected(index: int) -> void:
	palette_index = index
	%ShaderOverlay.update_colours(%ShaderOverlay.color_schemes.values()[palette_index])
