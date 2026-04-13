extends Area2D
class_name Entity

@export var base_hp = 10
@export var dmg_on_contact = 1
@export var i_frame_base = 6 # each hit will have roughly a 6-frame uptime. prevents double hits from one attack

var hp = 0
var timer_i_frame = 0

signal on_hurt

signal on_death

func _physics_process(delta: float) -> void:
	if timer_i_frame > 0:
		timer_i_frame -= 1

func _on_area_entered(area: Area2D) -> void:
	if area is Entity && timer_i_frame > 0:
		hurt(0,area as Entity)

func hurt(amount:int=1,attacker:Entity=null):
	if attacker or amount <= 0:
		hp -= attacker.dmg_on_contact
	else:
		hp -= amount
	check_health()

func check_health():
	if hp > base_hp:
		hp = base_hp
	
	if hp < 0:
		on_death.emit()
