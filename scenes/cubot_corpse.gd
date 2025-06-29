extends CharacterBody2D
class_name Corpse
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D


func _ready() -> void:
	#disable()
	pass

func spawn(pos:Vector2):
	global_position = pos
	velocity = Vector2(-700,-300)
	show()
	set_physics_process(true)
	sprite.play("idle")

func disable():
	hide()
	velocity *=0
	set_physics_process(false)

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y += Cubot.GRAVITY * delta
	velocity.x *= 0.90
	move_and_slide()
