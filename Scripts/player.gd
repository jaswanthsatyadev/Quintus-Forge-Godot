extends CharacterBody2D

class_name Player

const SPEED = 100.0
const JUMP_VELOCITY = -300.0

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var ladder_ray_cast: RayCast2D = $LadderRayCast
@onready var player_hit_box: Area2D = $playerHitBox

func _ready():
	Global.playerBody = self

func _physics_process(delta: float) -> void:
	@warning_ignore("unused_variable")
	var weaponEquip = Global.playerWeaponEquip
	Global.playerDamageZone = $playerDamageZone
	Global.playerHitBox = $playerHitBox
	
	var ladderCollider = ladder_ray_cast.is_colliding()
	
	if velocity.x != 0 and !ladderCollider:
		animated_sprite_2d.animation = "running"
	elif is_on_floor() and !ladderCollider:
		animated_sprite_2d.animation = "idle"
	
	if !is_on_floor():
		velocity += get_gravity() * delta
		animated_sprite_2d.animation = "jumping"
		
	if !is_on_floor() && ladder_ray_cast.is_colliding():
		animated_sprite_2d.animation = "climb"

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		animated_sprite_2d.animation = "jumping"
	
	#attacking
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		animated_sprite_2d.animation = "attack"
		
		
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("left", "right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	
	var isleft = velocity.x<0
	animated_sprite_2d.flip_h = isleft
	
	
	if ladderCollider: _ladder_climb(delta)
	else: pass
	
	move_and_slide()
	
	
	
	
func _ladder_climb(_delta):
	var direction = Vector2.ZERO
	direction.x = Input.get_axis("ui_left","ui_right")
	direction.y = Input.get_axis("ui_up","ui_down")
	
	if direction: 
		velocity = direction * (SPEED / 2)
		animated_sprite_2d.play("climb")
	else: 
		velocity = Vector2.ZERO
	
	if ladder_ray_cast.is_colliding():
		move_and_slide()
		animated_sprite_2d.play("climb")
	else:
		# Character is no longer on the ladder
		# Reset velocity and animation
		velocity = Vector2.ZERO
		animated_sprite_2d.animation = "idle"
	
