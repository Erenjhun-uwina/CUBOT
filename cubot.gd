extends CharacterBody2D


const JUMP_VELOCITY = -1500.0
const  GRAVITY  = 3000


func _physics_process(delta: float) -> void:
	
	if not is_on_floor():
		velocity.y += GRAVITY * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	if not Input.is_action_just_pressed("ui_accept") and   velocity.y <= 0:
		velocity.y *= 0.2

	print(velocity)

	move_and_slide()
