extends KinematicBody2D

var velocity = Vector2.ZERO

export(int) var MAX_SPEED = 50
export(int) var ACCELERATION = 300
export(int) var FRICTION = 300
export(int) var KNOCKBACK_FORCE = 100
export(int) var MAX_HEALTH = 100
#export(int) var BASE_DAMAGE = 20

onready var health = MAX_HEALTH setget _set_health
onready var knockback_force = KNOCKBACK_FORCE

onready var collisionShape = $CollisionShape2D
onready var animationPlayer = $AnimationPlayer
onready var position2D = $Position2D
onready var hitbox = $Position2D/Hitbox
onready var hitCollisionShape = $Position2D/Hitbox/CollisionShape2D
onready var cooldown = $Position2D/Hitbox/Cooldown
onready var hurtbox = $Hurtbox
onready var hurtCollisionShape = $Hurtbox/CollisionShape2D
onready var hurtTimer = $Hurtbox/HurtTimer

signal health_updated(health)
signal killed()

func _physics_process(_delta):
	move()

func move():
	velocity = move_and_slide(velocity)

func _set_health(value):
	var prev_health = health
	health = clamp(value, 0, MAX_HEALTH)
	if health != prev_health:
		emit_signal("health_updated", health)
		if health == 0:
			emit_signal("killed")

func get_damaged(value):
	var new_health = health - value
	_set_health(new_health)
