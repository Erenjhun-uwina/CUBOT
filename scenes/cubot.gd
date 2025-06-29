extends CharacterBody2D
class_name Cubot


@export var runner:Runner
var cpu:CPU 


@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

const GRAVITY : int = 2500
const JUMP_SPEED : int = -1300
const MAX_JUMP_HEIGHT := 350  # Max height above jump start

@onready var run_col: Area2D = $run_col


var x:
	get():return global_position.x
	set(val):return
var y:
	get():return global_position.y
	set(val):return


var jump_start_y := 0.0
var is_jumping := false

var DINO_START_POS

func _ready() -> void:
	cpu  = CPU.new(self)
	DINO_START_POS = position

func _physics_process(delta):
	
	cpu.loop(delta)
		
	
	velocity.y += GRAVITY * delta

	if is_on_floor():
		is_jumping = false
		jump_start_y = position.y  # reset jump origin

		run_col.monitorable = true
		

		if cpu.has_jump_request:
			velocity.y = JUMP_SPEED
			is_jumping = true
			jump_start_y = position.y
			$JumpSound.play()

		elif cpu.has_duck_request:
			sprite.play("duck")
			run_col.monitorable = false
		else:
			sprite.play("run")
	else:
		if is_jumping:
			var jumped_distance = jump_start_y - position.y
			var reached_max_height = jumped_distance >= MAX_JUMP_HEIGHT

			if reached_max_height or not cpu.has_jump_request: 
				is_jumping = false
				
				if velocity.y < 0:
					velocity.y *=0.3 # Stop upward motion immediately

	#sprite.play("jump")


	move_and_slide()

func respawn()->void:
	show()
	set_physics_process(true)
	position = DINO_START_POS
	velocity = Vector2i(0, 0)
	sprite.play("idle")

func die()->void:
	
	hide()
	set_physics_process(false)
