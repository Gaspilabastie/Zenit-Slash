extends "res://Entities/Enemies/EnemyBase.gd"

onready var animatedSprite = $AnimatedSprite

enum {
	Idle,
	Fire,
	Hurt,
	Die
}
var state = Idle

func _ready():
	animatedSprite.set_playing(false)

func _physics_process(delta):
	
	match state:
		Idle:
			animationPlayer.play("Idle")
			velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)
			seek_player()
		
		Fire:
			var player = playerDetectionZone.player
			animationPlayer.play("Fire")
			if player != null:
				animatedSprite.flip_h = player.global_position.x > global_position.x
				fire_towards(player.global_position, delta)
			else:
				state = Idle
		
		Hurt:
			animationPlayer.play("GetDamaged")
			if hurtTimer.time_left == 0:
				state = Idle
			
		Die:
			velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)
			hitCollisionShape.set_disabled(true)
			hurtCollisionShape.set_disabled(true)
			animationPlayer.play("Explode")
	
	soft_collide(delta)
	get_pushed(delta)
	move()

func seek_player():
	if playerDetectionZone.can_see_player():
		state = Fire

func fire_towards(point, delta):
	pass

func _on_Hurtbox_area_entered(area):
	knockback = area.owner.global_position.direction_to(hurtbox.owner.global_position).normalized() * area.owner.knockback_force
	velocity = Vector2.ZERO
	get_damaged(area.damage)
	if health == 0:
		state = Die
	else:
		hurtTimer.start()
		state = Hurt
