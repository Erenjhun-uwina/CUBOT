extends CharacterBody2D
class_name Cubot


@export var runner:Runner
var cpu:CPU 


@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

const GRAVITY : int = 2500 
const JUMP_SPEED : int = -1300
const MAX_JUMP_HEIGHT := 350  # Max height above jump start

@onready var run_col: Area2D = $run_col
@onready var shape: CollisionShape2D = $run_col/shape

var speed:float:
	get():return runner.speed

var size:Vector2:

	get():return shape.shape.get_rect().size.rotated(shape.global_rotation).abs() * shape.global_scale

var width:float:
	get():
		return size.x

var height:float:
	get():
		return size.y


var x:float:
	get():return global_position.x
	set(val):return
var y:float:
	get():return global_position.y
	set(val):return


var jump_start_y := 0.0
var is_jumping := false

var DINO_START_POS

func _ready() -> void:
	cpu  = CPU.new(self)
	DINO_START_POS = position

func _physics_process(delta):
	
	if not is_instance_valid(cpu) :return
	cpu.loop(delta)
		
	
	velocity.y += GRAVITY * delta

	if is_on_floor():
		is_jumping = false
		jump_start_y = position.y  # reset jump origin

		run_col.monitorable = true
		run_col.position.y = 0
		
		if cpu.has_jump_request:
			velocity.y = JUMP_SPEED
			is_jumping = true
			jump_start_y = position.y
			($JumpSound as AudioStreamPlayer).pitch_scale = randf_range(0.5,1.5)
			($JumpSound as AudioStreamPlayer).play()

		elif cpu.has_duck_request:
			sprite.play("duck")
			if not $AnimationPlayer.current_animation == "duck":
				$AnimationPlayer.play("duck")
				run_col.position.y = 10000000
		else:
			if not $AnimationPlayer.current_animation == "hover":
				$AnimationPlayer.play("hover")
			
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
	process_mode = Node.PROCESS_MODE_INHERIT
	position = DINO_START_POS
	velocity = Vector2i(0, 0)
	sprite.play("idle")

func die()->void:
	cpu.queue_free()
	hide()
	process_mode = Node.PROCESS_MODE_DISABLED
