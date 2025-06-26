extends CharacterBody2D
class_name Cubot


@export var runner:Runner
var cpu:CPU 

const GRAVITY : int = 2600
const JUMP_SPEED : int = -1500
const MAX_JUMP_HEIGHT := 250  # Max height above jump start


var jump_start_y := 0.0
var is_jumping := false


func _ready() -> void:
	cpu  = CPU.new(self)

func _physics_process(delta):
	
	cpu.loop(delta)
	
	velocity.y += GRAVITY * delta

	if is_on_floor():
		is_jumping = false
		jump_start_y = position.y  # reset jump origin

		$RunCol.disabled = false

		if cpu.has_jump_request:
			velocity.y = JUMP_SPEED
			is_jumping = true
			jump_start_y = position.y
			$JumpSound.play()

		elif cpu.has_duck_request:
			$AnimatedSprite2D.play("duck")
			$RunCol.disabled = true
		else:
			$AnimatedSprite2D.play("run")
	else:
		if is_jumping:
			var jumped_distance = jump_start_y - position.y
			var reached_max_height = jumped_distance >= MAX_JUMP_HEIGHT

			if reached_max_height or not cpu.has_jump_request: 
				is_jumping = false
				if velocity.y < 0:
					velocity.y *=0.3 # Stop upward motion immediately

	$AnimatedSprite2D.play("jump")


	move_and_slide()
