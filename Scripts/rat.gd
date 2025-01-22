extends CharacterBody2D

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

var speed = 25
var player_chase = false
var player =  null

func _physics_process(delta: float) -> void: 
	if player_chase:
		position += (player.position - position)/speed

func _on_dectection_area_body_entered(body):
	player = body
	player_chase = true
func _on_dectection_area_body_exited(body):
	player = null
	player_chase = false


	
