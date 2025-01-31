extends CharacterBody2D


class_name Player


#constants

const SPEED = 100.0
const JUMP_VELOCITY = -300.0
var is_attack_cooldown: bool = false
var currentPlayerHp = Global.playerhp

@onready var health_bar: ProgressBar = $HealthBar
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var ladder_ray_cast: RayCast2D = $LadderRayCast
@onready var player_hit_box: Area2D = $playerHitBox
@onready var attack_cooldown_timer: Timer = $AttackCooldownTimer
@onready var collision_hitbox_2d: CollisionShape2D = $playerHitBox/CollisionShape2D

enum State { IDLE, RUNNING, JUMPING, CLIMBING, ATTACKING }
var current_state = State.IDLE

func _ready():
	collision_hitbox_2d.disabled = true
	Global.playerBody = self
	health_bar.max_value = 100
	currentPlayerHp = 100
	set_health_bar()

func _physics_process(delta: float) -> void:
	if current_state == State.ATTACKING and animated_sprite_2d.is_playing():
		move_and_slide()
		return
	
	Global.playerDamageZone = $playerDamageZone
	Global.playerHitBox = $playerHitBox
	
	var ladderCollider = ladder_ray_cast.is_colliding()
	
	if velocity.x != 0 and !ladderCollider:
		animated_sprite_2d.play("running")
	elif is_on_floor() and !ladderCollider:
		animated_sprite_2d.play("idle")
	
	if !is_on_floor():
		velocity += get_gravity() * delta
		animated_sprite_2d.play("jumping")
		
	if !is_on_floor() && ladder_ray_cast.is_colliding():
		animated_sprite_2d.play("climb")

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		current_state = State.JUMPING
		animated_sprite_2d.animation = "jumping"
	
	#attacking
	# Replace the existing attack code with:
	if Input.is_action_just_pressed("attack") and is_on_floor():
		if !is_attack_cooldown:
			current_state = State.ATTACKING
			animated_sprite_2d.play("attack1")
			velocity.x = 0
			collision_hitbox_2d.disabled = false
			is_attack_cooldown = true
			$AttackCooldownTimer.start(0.8)
		
		move_and_slide()
		return
	
	current_state = State.IDLE
	

	var direction := Input.get_axis("left", "right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	
	var isleft = velocity.x < 0
	animated_sprite_2d.flip_h = isleft
	
	
	if ladderCollider: _ladder_climb(delta)
	else:
		current_state = State.IDLE
	
	move_and_slide()
	
func _ladder_climb(_delta):
	var direction = Vector2.ZERO
	direction.x = Input.get_axis("ui_left","ui_right")
	direction.y = Input.get_axis("ui_up","ui_down")
	
	if direction: 
		velocity = direction * (SPEED / 2)
		current_state = State.CLIMBING
		animated_sprite_2d.play("climb")
	else: 
		velocity = Vector2.ZERO
		animated_sprite_2d.play("climb")
	
	if ladder_ray_cast.is_colliding():
		animated_sprite_2d.play("climb")
	else:
		# Character is no longer on the ladder
		# Reset velocity and animation
		#velocity = Vector2.ZERO
		current_state = State.IDLE
		animated_sprite_2d.animation = "idle"

func _on_attack_cooldown_timer_timeout() -> void:
	is_attack_cooldown = false
	

func set_health_bar() -> void:
	health_bar.value = currentPlayerHp

func damage():
	currentPlayerHp -= Global.EnemyDamgeAmount
	if currentPlayerHp <= 0:
		get_tree().reload_current_scene()
	else:
		pass
