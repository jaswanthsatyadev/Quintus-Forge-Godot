extends CharacterBody2D

class_name ratenemy
const speed = 50
var is_rat_chase : bool 
var health = 80
var health_max = 80 
var health_min = 0
var dead: bool = false
var taking_damage: bool = false
var damage_to_deat = 20
var is_deating_damage: bool = false

var dir: Vector2
const gravity = 900
var knockback_force = 200
var is_roaming: bool = true

func _ready():
	is_rat_chase = false

func choose(array):
	array.shuffle()
	return array.front()
	
func _on_timer_timeout():
	$Timer.wait_time = choose([1.5,2,2.5])
	if !is_rat_chase:
		dir = choose([Vector2.RIGHT,Vector2.LEFT])
		print(dir)
		
	
func _process(delta):
	if !is_on_floor():
		velocity.y += gravity*delta			
		velocity.x = 0
	move(delta)
	move_and_slide()
	
func move(delta):
	if !dead:
		if !is_rat_chase:
			velocity += dir*speed*delta
		is_roaming = true
	elif dead:
		velocity.x = 0
