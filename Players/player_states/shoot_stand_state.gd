extends NodeState

var bullet = preload("res://Players/bullet.tscn")

@export var character_body_2d : CharacterBody2D
@export var animated_sprite_2d : AnimatedSprite2D
@export var muzzle : Marker2D
@export var hold_gun_time : float = 1

var muzzle_position : Vector2

func on_process(delta : float):
	pass


func on_physics_process(delta : float):
	
	gun_muzzle_position()
	
	if GameInputEvents.shoot_input():
		gun_shooting()
	
	# transitioning states
	
	# run state
	var direction : float = GameInputEvents.movement_input()
	
	if direction and character_body_2d.is_on_floor():
		transition.emit("Run")
	
	# jump state
	if GameInputEvents.jump_input():
		transition.emit("Jump")


func enter():
	muzzle.position = Vector2(19, -27)
	muzzle_position = muzzle.position

	animated_sprite_2d.play("shoot-stand")

	var timer = get_tree().create_timer(hold_gun_time)
	timer.timeout.connect(on_hold_gun_timout)

func exit():
	animated_sprite_2d.stop()


func on_hold_gun_timout():
	transition.emit("Idle")


func gun_muzzle_position():
	if !animated_sprite_2d.flip_h:
		muzzle.position.x = muzzle_position.x
	elif animated_sprite_2d.flip_h:
		muzzle.position.x = -muzzle_position.x


func gun_shooting():
	print("Shooting bullet...")
	var direction : float = -1 if animated_sprite_2d.flip_h else 1

	var bullet_instance = bullet.instantiate() as Node2D
	bullet_instance.direction = direction
	bullet_instance.move_x_direction = true
	bullet_instance.global_position = muzzle.global_position
	get_parent().add_child(bullet_instance)
