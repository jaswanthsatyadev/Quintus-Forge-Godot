extends CharacterBody2D

#class initiation 
class_name Enemy

#vars and constants
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var direction_timer: Timer = $DirectionTimer
@onready var player_detection_area: Area2D = $"../PlayerDetectionArea"
@onready var enemy_deal_damage_area: Area2D = $"../EnemyDealDamageArea"
@onready var player_hit_box: Area2D = $playerHitBox

const CHASE_RANGE = 315
const SPEED = 30
var is_chasing_player: bool = true

var health = 150
var health_max = 150
var health_min = 0

var dead: bool = false
var taking_damage: bool = false
var damage_to_deal = 15
var is_dealing_damage: bool = false

var dir: Vector2
const gravity = 900
var knockback_force = -20
var is_roaming: bool = false
var player_in_area = false
var nearby: bool = false

func _process(delta):
	if !is_on_floor():
		velocity.y = gravity * delta
		velocity.x = 0
	
	Global.EnemyDamgeAmount = damage_to_deal
	Global.EnemyDamageZone = enemy_deal_damage_area
	
	move(delta)
	move_and_slide()

func move(delta):
	if !dead:
		if !is_chasing_player:
			velocity += dir * SPEED * delta
		elif is_chasing_player and !taking_damage:
			var dir_to_player = position.direction_to(Global.playerBody.global_position)
			velocity.x = dir_to_player.x * SPEED
			dir.x = sign(velocity.x)
		elif taking_damage:
			var knockback_dir = position.direction_to(Global.playerBody.global_position)
			var knockback_velocity = knockback_dir * knockback_force
			velocity.x = knockback_velocity.x
		is_roaming = true
			
			
	elif dead:
		velocity.x = 0


func _on_player_detection_area_body_entered(body: Node2D) -> void:
	if body == Global.playerBody:
		is_chasing_player = true


func _on_player_detection_area_body_exited(body: Node2D) -> void:
	if body != Global.playerBody:
		is_chasing_player = false

func _on_direction_timer_timeout() -> void:
	$DirectionTimer.wait_time = choose([1.5,2.0,2.5])
	if !is_chasing_player:
		dir = choose([Vector2.LEFT, Vector2.RIGHT])
		velocity.x = 0
		

func handle_animations():
	var anim_sprite = $AnimatedSprite2D
	if !dead and !is_dealing_damage and !taking_damage:
		anim_sprite.play("walk")
		if dir.x == -1:
			anim_sprite.flip_h = true
		elif dir.x == 1:
			anim_sprite.flip_h = false
	elif !dead and taking_damage and !is_dealing_damage:
		anim_sprite.play("hurt")
		@warning_ignore("redundant_await")
		await get_tree().create_timer(0.8)
		taking_damage = false
	elif dead and is_roaming:
		is_roaming = false
		anim_sprite.play("death")
		await get_tree().create_timer(5.5).timeout
	elif !dead and is_dealing_damage:
		anim_sprite.play("attack")
		
		handle_death()

func handle_death():
	self.queue_free()
	

func choose(list):
	list.shuffle()
	return list.front()


func _on_enemy_hit_box_area_entered(area: Area2D):
	var damage = Global.playerDamageAmount
	if area == Global.playerDamageZone:
		take_damage(damage)

func take_damage(damage):
	health -= damage
	taking_damage = true
	if health <= health_min:
		health = health_min
		dead = true
