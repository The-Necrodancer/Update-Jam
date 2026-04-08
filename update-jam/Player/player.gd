extends CharacterBody2D
class_name Player

@export var ground_check_cast : ShapeCast2D

#movement variables
var move_input : Vector2 = Vector2.ZERO

const walk_accel : float = 700

const grounded_friction : float = 3
const air_friction : float = 1

#jumping variables
const gravity_accel : float = 1000
const jump_vel : float = 400
var is_grounded : bool = true

#coyote time 
const coyote_time : float = 0.2
var timer_coyote : float = 0.0

#jump cooldown (prevents jumping multiple times)
const jump_cooldown : float = 0.2
var timer_jumpcd : float = 0.2

#some variables for later
const max_wall_slide_vel = 5 # make it so that when wall sliding we have like `velocity = max(velocity.y,max_wall_slide_vel)`

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

func jump():
	if (timer_coyote > 0 or is_grounded) and timer_jumpcd <= 0:
		velocity.y = jump_vel * -1
		timer_jumpcd = jump_cooldown

func jump_release():
	if velocity.y < 0:
		velocity.y = velocity.y * 0.4
