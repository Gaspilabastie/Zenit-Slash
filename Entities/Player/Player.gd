extends "res://Entities/EntityBase.gd"

onready var animatedSprite = $AnimatedSprite
onready var animationTree = $AnimationTree
onready var animationState = animationTree.get("parameters/playback")

enum {
	Move,
	Attack,
	Roll,
	Heal,
	Die
}
var state = Move
var set_healing = false

func _ready():
	animatedSprite.set_playing(false)
	animationTree.active = true
	
func _physics_process(delta):
	match state:
		Move:
			move_state(delta)
		
		Attack:
			attack_state(delta)
		
		Roll:
			roll_state()
		
		Heal:
			heal_state(delta)
		
		Die:
			die_state(delta)
	
	move()

func move_state(delta):
	var input_vector = Vector2.ZERO

	input_vector.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	input_vector.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	input_vector = input_vector.normalized()

	if input_vector != Vector2.ZERO:
		velocity = velocity.move_toward(input_vector * MAX_SPEED, ACCELERATION * delta)
		animationState.travel("Run")
		animatedSprite.flip_h = input_vector.x < 0
		flip_hitbox(input_vector)
	else:
		velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)
		animationState.travel("Idle")
	
	if Input.is_action_just_pressed("attack"):
		cooldown.start()
		state = Attack
	
	if Input.is_action_just_pressed("roll") and velocity != Vector2.ZERO:
		state = Roll
	
	if Input.is_action_just_pressed("heal"):
		print(health)
		state = Heal

func flip_hitbox(input_vector):
	position2D.scale.x = -2 * int(input_vector.x < 0) + 1

func attack_state(delta):
	velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)
	animationState.travel("Weak Attack 1")
	if Input.is_action_just_pressed("attack") and (cooldown.time_left == 0.0):
		match animationState.get_current_node():
			"Weak Attack 1":
				animationState.travel("Weak Attack 2")
				cooldown.start()
			"Weak Attack 2":
				knockback_force = KNOCKBACK_FORCE * 1.5
				animationState.travel("Weak Attack 3")

func attack_animation_finished():
	knockback_force = KNOCKBACK_FORCE
	state = Move

func roll_state():
	velocity = velocity.normalized() * MAX_SPEED * 1.2
	animationState.travel("Roll")

func finish_roll_state():
	state = Move

func heal_state(delta):
	velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)
	animationState.travel("Heal")

func healing():
	_set_health(health + 30)

func finish_heal_state():
	print(health)
	state = Move

func die_state(delta):
	velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)
	animationState.travel("Die")
	health = 0

func _on_Hurtbox_area_entered(area):
	if hurtTimer.time_left == 0:
		hurtTimer.start()
		animationPlayer.play("GetDamaged")
		get_damaged(area.damage)
		hurtbox.set_deferred("monitoring", false)
		if health == 0:
			hurtCollisionShape.queue_free()
			collisionShape.queue_free()
			state = Die

func _on_HurtTimer_timeout():
	if health != 0:
		hurtbox.set_deferred("monitoring", true)
