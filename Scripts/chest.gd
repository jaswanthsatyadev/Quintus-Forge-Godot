extends Area2D

@onready var sprite = $AnimatedSprite2D

func _on_body_entered(body):
	if body.name == "player":  # Change this to your player’s node name
		sprite.play("chest_open")
		set_deferred("monitoring", false)  # Disables further triggers
		print("playrt entered")
# Connect this function to the "body_entered" signal of the Area2D node
