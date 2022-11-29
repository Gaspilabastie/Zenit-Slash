extends "res://Entities/EntityBase.gd"

onready var playerDetectionZone = $PlayerDetectionZone
onready var softCollision = $SoftCollision

var knockback = Vector2.ZERO

func get_pushed(delta):
	knockback = knockback.move_toward(Vector2.ZERO, FRICTION * delta)
	knockback = move_and_slide(knockback)

func soft_collide(delta):
	if softCollision.is_colliding():
		velocity += softCollision.get_push_vector() * delta * softCollision.SOFT_COLLIDE_FORCE
