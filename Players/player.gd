extends CharacterBody2D
var bullet = preload("res://Players/bullet.tscn")
var player_death_effect = preload("res://Players/player_death_effect/player_death_effect.tscn")

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var muzzle: Marker2D = $Muzzle
@onready var hit_animation_player: AnimationPlayer = $HitAnimationPlayer

const GRAVITY = 1000

@export var jump : int = -400
@export var speed : int = 500  
#@export var slow_down_speed:int=3500
@export var max_horizontal_speed : int = 300
@export var jump_horizontal_speed : int = 1000
@export var max_jump_horizontal_speed : int = 300
@export var jump_count : int = 2
var shoot_duration := 0.3 # seconds
var shoot_timer := 0.0


enum State { Idle, Run, Jump, ShootIdle, ShootRun,Crouch }

var current_state : State
var muzzle_position 
var current_jump_count : int

var character_sprite : Sprite2D  

func _ready():
	current_state = State.Idle
	muzzle_position = muzzle.position

func _physics_process(delta: float):
	player_falling(delta)
	player_jump(delta)
	player_crouch(delta)
	player_muzzle_position()
	player_shooting(delta)

	# Update shooting cooldown
	if shoot_timer > 0:
		shoot_timer -= delta
		if shoot_timer <= 0:
			if is_on_floor():
				var direction = input_movement()
				if current_state in [State.ShootIdle, State.ShootRun]:
					current_state = State.Run if direction != 0 else State.Idle
	else:
		if current_state != State.Crouch and current_state not in [State.ShootIdle, State.ShootRun, State.Jump]:
			player_idle(delta)
			player_run(delta)

	move_and_slide()
	player_animations()



func player_falling(delta: float):
	if not is_on_floor():
		velocity.y += GRAVITY * delta
		if velocity.y > 0 and current_state != State.Jump:
			current_state = State.Jump
	else:
		# Player is grounded, clear jump state
		if current_state == State.Jump:
			var direction = input_movement()
			current_state = State.Run if direction != 0 else State.Idle



func player_idle(delta : float):
	if is_on_floor() and current_state != State.Jump and shoot_timer <= 0:
		current_state = State.Idle
		
		
func player_crouch(delta: float):
	if is_on_floor() and Input.is_action_pressed("crouch"):
		current_state = State.Crouch
		velocity.x = 0 
	else:
		if current_state == State.Crouch:
			var direction = input_movement()
			current_state = State.Run if direction != 0 else State.Idle

		
func player_run(delta : float):
	if !is_on_floor() or current_state == State.Jump:
		return
	if Input.is_action_pressed("shoot"):
		return  # let shooting logic handle movement during shooting

	var direction = input_movement()
	if direction:
		velocity.x = direction * max_horizontal_speed
		current_state = State.Run
		animated_sprite_2d.flip_h = direction < 0
	else:
		velocity.x = 0
		current_state = State.Idle

	
func player_jump(delta: float):
	var jump_input : bool = Input.is_action_just_pressed("jump")
	if is_on_floor() and jump_input:
		current_jump_count = 0
		velocity.y = jump
		current_jump_count += 1
		current_state = State.Jump
	if !is_on_floor() and jump_input and current_jump_count < jump_count:
		velocity.y = jump
		current_jump_count += 1
		current_state = State.Jump
	if  !is_on_floor() and current_state == State.Jump:
		var direction = input_movement()
		velocity.x += direction * jump_horizontal_speed * delta
		velocity.x = clamp(velocity.x, -max_jump_horizontal_speed, max_jump_horizontal_speed)

		
func player_shooting(delta: float):
	var direction = input_movement()

	if Input.is_action_pressed("shoot"):
		# Only shoot if timer allows
		if shoot_timer <= 0:
			var bullet_instance = bullet.instantiate() as Node2D
			bullet_instance.direction = direction if direction != 0 else (1 if not animated_sprite_2d.flip_h else -1)
			bullet_instance.global_position = muzzle.global_position
			get_parent().add_child(bullet_instance)

			shoot_timer = shoot_duration  # Start cooldown

		# Set proper shoot state without resetting shoot_timer
		if is_on_floor():
			if direction != 0:
				current_state = State.ShootRun
				velocity.x = direction * max_horizontal_speed
				animated_sprite_2d.flip_h = direction < 0
			else:
				current_state = State.ShootIdle
				velocity.x = 0
	else:
		# Do not reset timer here; let it count down naturally
		pass
	
func player_muzzle_position():
	var direction = input_movement()
	if direction > 0 :
		muzzle.position.x = muzzle_position.x
	elif direction < 0:
		muzzle.position.x = -muzzle_position.x


func player_animations():
	match current_state:
		State.Idle:
			if animated_sprite_2d.animation != "idle":
				animated_sprite_2d.play("idle")
		State.Crouch:
			if animated_sprite_2d.animation != "crouch":
				animated_sprite_2d.play("crouch")
		State.Jump:
			if animated_sprite_2d.animation != "jump":
				animated_sprite_2d.play("jump")
		State.Run:
			if animated_sprite_2d.animation != "run":
				animated_sprite_2d.play("run")
		State.ShootIdle:
			if animated_sprite_2d.animation != "shoot":
				animated_sprite_2d.play("shoot")
		State.ShootRun:
			if animated_sprite_2d.animation != "run_shoot":
				animated_sprite_2d.play("run_shoot")



func player_death():
	var player_death_effect_instance = player_death_effect.instantiate() as Node2D
	player_death_effect_instance.global_position = global_position
	get_parent().add_child(player_death_effect_instance)
	queue_free()


func input_movement():
	var direction : float = Input.get_axis("move_left","move_right")
	return direction
	


func _on_hurtbox_body_entered(body: Node2D):
	if body.is_in_group("Enemy"):
		#print("Enemy entered ",body.damage_amount)
		hit_animation_player.play("hit")
		HealthManager.decrease_health(body.damage_amount)
	elif body.is_in_group("Enemy2"):
		#print("Enemy entered dino ",body.damage_amount)
		hit_animation_player.play("hit")
		HealthManager.decrease_health(body.damage_amount)
	
	if HealthManager.current_health == 0:
		player_death() 
