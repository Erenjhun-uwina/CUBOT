extends Node
class_name  Runner

#preload obstacles
var stump_scene = preload("res://scenes/obstacles/scene/stump.tscn")
var rock_scene = preload("res://scenes/obstacles/scene/rock.tscn")
var barrel_scene = preload("res://scenes/obstacles/scene/barrel.tscn")
var drone_scene = preload("res://scenes/obstacles/scene/drone.tscn")
var obstacle_types := [stump_scene, rock_scene, barrel_scene]
var bird_heights := [450,300,500]

#game variables
var difficulty
const MAX_DIFFICULTY : int = 5
var score : int
const SCORE_MODIFIER : int = 10
var high_score : int
var speed : float
const START_SPEED : float = 10
const MAX_SPEED : int = 100
const SPEED_MODIFIER : int = 2000
var screen_size : Vector2i
var ground_height : int
var last_obs

@export var cubot:Cubot
@onready var gameover_screen: Gameover_screen = $GameOver
@onready var code_ui = $HUD2/Code_UI
@onready var camera: Camera2D = $SubViewport/cubot/Camera2D
@onready var corpse: Corpse = $SubViewport/corpse
@onready var HUD: CanvasLayer = $gameview/HUD
@onready var timer: Timer = $Timer

# Called when the node enters the scene tree for the first time.


func _unhandled_key_input(event: InputEvent) -> void:
	if Input.is_key_pressed(KEY_ESCAPE):
		game_over()

func _ready():
	
	get_tree().paused = true
	screen_size = get_window().size 
	ground_height = $SubViewport/Ground.get_node("Sprite2D").texture.get_height()
	gameover_screen.tryagain.connect(code_ui.show)
	code_ui.run.connect(new_game)
	timer.timeout.connect(generate_obs)

func _notification(what: int) -> void:
	if what == NOTIFICATION_UNPAUSED:
		$AudioStreamPlayer.play()
		$AudioStreamPlayer.volume_db = -80
		var twn:=create_tween()
		twn.tween_property($AudioStreamPlayer,"volume_db",0,3).set_ease(Tween.EASE_OUT)



func new_game():
	
	score = 0
	$gameview/HUD.show()
	show_score()
	get_tree().paused = false
	difficulty = 0
	
	for obs:Obstacle in get_tree().get_nodes_in_group("obstacle"):
		obs.queue_free()
	
	#reset the nodes
	cubot.respawn()
	corpse.disable()
	$SubViewport/Ground.position = Vector2i(0, 0)
	set_process(true)
	timer.start(-1)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	cubot.cpu.clear_requests()
		
	#speed up and adjust difficulty
	speed = START_SPEED + score / SPEED_MODIFIER
	if speed > MAX_SPEED:
		speed = MAX_SPEED
	adjust_difficulty()
	
	
	#move dino and camera
	cubot.position.x += speed
	
	#update score
	score += speed
	show_score()
	
	#update ground position
	$SubViewport/Ground.global_position.x =  cubot.position.x - 300
	$SubViewport/Ground.global_position.y =  544
	
		

func generate_obs():
	#generate ground obstacles
	var rand = randf()
	
	var obs_type = obstacle_types.pick_random()
	var obs:Obstacle
	var max_obs = difficulty + 1
	
	var obs_count:int=(randi() % max_obs + 1)
	
	var obs_x : int
	var obs_y : int
	 
	if (randi() % MAX_DIFFICULTY) > difficulty:
		obs = obs_type.instantiate()
		var obs_height = obs.get_node("Sprite2D").texture.get_height()
		var obs_scale = obs.get_node("Sprite2D").scale
		obs_x  = screen_size.x + score 
		obs_y  =  $SubViewport/Ground.global_position.y - 15
		last_obs = obs
		add_obs(obs, obs_x, obs_y)
		obs.position.x + obs.width/2
	else:
		obs = drone_scene.instantiate()
		obs_x  = screen_size.x + score + 50
		obs_y  = bird_heights.pick_random()
		add_obs(obs, obs_x, obs_y)

	var next_spawn:float = obs.width/(50 + score/400)
	next_spawn = max(next_spawn,0.2)
	timer.start(next_spawn)
	
	print(next_spawn)
	
func add_obs(obs:Obstacle, x, y):
	obs.global_position = Vector2i(x, y)
	obs.area_entered.connect(hit_obs)
	$SubViewport.add_child(obs)


func hit_obs(body):
	#return  
	print("hit")
	cubot.die()
	corpse.spawn(cubot.global_position)
	game_over()
	

func show_score():
	HUD.get_node("ScoreLabel").text = "SCORE: " + str(score / SCORE_MODIFIER)

func check_high_score():
	if score > high_score:
		high_score = score
		HUD.get_node("HighScoreLabel").text = "HIGH SCORE: " + str(high_score / SCORE_MODIFIER)

func adjust_difficulty():
	difficulty = score / SPEED_MODIFIER
	if difficulty > MAX_DIFFICULTY:
		difficulty = MAX_DIFFICULTY

func game_over():
	check_high_score()
	set_process(false)
	cubot.set_process(false)
	$gameview/HUD.hide()
	timer.stop()
	var twn:=create_tween()
	twn.tween_property($AudioStreamPlayer,"volume_db",-80,1).set_ease(Tween.EASE_OUT)
	await get_tree().create_timer(.8).timeout
	$GameOver.show()
