extends CharacterBody2D
class_name Player

@export var ground_check_cast : ShapeCast2D

@export var wall_check_right : ShapeCast2D
@export var wall_check_left : ShapeCast2D

#"unlock" variables
var can_wall_jump : bool = true
var can_climb : bool = false

#movement variables
var move_input : Vector2 = Vector2.ZERO

const walk_accel : float = 700

const grounded_friction : float = 3
const air_friction : float = 1

#jumping variables
const gravity_accel : float = 1000
const jump_vel : float = 500
var is_grounded : bool = true

#coyote time 
const coyote_time : float = 0.2
var timer_coyote : float = 0.0

#jump cooldown (prevents jumping multiple times)
const jump_cooldown : float = 0.2
var timer_jumpcd : float = 0.2

#wall sliding + jumping
const max_wall_slide_vel = 80
var is_wall_sliding : bool = false
var timer_wall_slide_cd : float = 0.2
const wall_slide_cooldown : float = 0.2
const wall_jump_speed : float = 400

func _ready() -> void:
	pass

func _physics_process(delta: float) -> void:
	#get input
	move_input = Input.get_vector("left","right","up","down")
	
	run_timers(delta)
	
	check_grounded()
	
	#base horizontal movement
	if is_grounded:
		velocity.x += move_input.x * walk_accel * delta 
		velocity.x -= velocity.x * grounded_friction * delta
	else:
		velocity.x += move_input.x * walk_accel * delta 
		velocity.x -= velocity.x * air_friction * delta
	
	velocity.y += gravity_accel * delta 
	
	if Input.is_action_just_pressed("jump"):
		jump()
	if Input.is_action_just_released("jump"):
		jump_release()
	
	#wall slide
	if(velocity.y > 0):
		if(get_wall_dir() != 0  && can_wall_jump && timer_wall_slide_cd <= 0):
			velocity.y = min(max_wall_slide_vel,velocity.y)
			is_wall_sliding = true
		else:
			is_wall_sliding = false
	else:
		is_wall_sliding = false
	
	move_and_slide()

func check_grounded():
	var g = ground_check_cast.is_colliding()
	if !g && is_grounded:
		timer_coyote = coyote_time
	is_grounded = g

func run_timers(delta):
	if timer_jumpcd > 0:
		timer_jumpcd -= delta
	if timer_coyote > 0:
		timer_coyote -= delta
	if timer_wall_slide_cd > 0:
		timer_wall_slide_cd -= delta

func jump():
	#detect if its a wall or ground jump
	#ground jump
	if (timer_coyote > 0 or is_grounded) and timer_jumpcd <= 0:
			velocity.y = jump_vel * -1
			timer_jumpcd = jump_cooldown
			is_grounded = false
	else: #deprioritizes the walljump by being secondary to grounded
		if(timer_jumpcd <= 0 && can_wall_jump && get_wall_dir() != 0 && is_wall_sliding):
			velocity = Vector2(-1 * get_wall_dir() * wall_jump_speed,jump_vel * -1)
			timer_jumpcd = jump_cooldown
			is_grounded = false
			is_wall_sliding = false
			timer_wall_slide_cd = wall_slide_cooldown

func jump_release():
	if velocity.y < 0:
		velocity.y = velocity.y * 0.6

#gets wall directions
func get_wall_dir():
	if !can_wall_jump:
		return 0
	if wall_check_left.is_colliding():
		return -1
	if wall_check_right.is_colliding():
		return 1
	return 0
