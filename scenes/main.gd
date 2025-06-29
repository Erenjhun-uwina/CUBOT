extends Node
class_name  Runner

#preload obstacles
var stump_scene = preload("res://scenes/obstacles/scene/stump.tscn")
var rock_scene = preload("res://scenes/obstacles/scene/rock.tscn")
var barrel_scene = preload("res://scenes/obstacles/scene/barrel.tscn")
var drone_scene = preload("res://scenes/obstacles/scene/drone.tscn")
var obstacle_types := [stump_scene, rock_scene, barrel_scene]
var bird_heights := [500,300]

#game variables
var difficulty
const MAX_DIFFICULTY : int = 5
var score : int
const SCORE_MODIFIER : int = 10
var high_score : int
var speed : float
const START_SPEED : float = 10
const MAX_SPEED : int = 30
const SPEED_MODIFIER : int = 4000
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
func _ready():
	get_tree().paused = true
	
	screen_size = get_window().size
	ground_height = $SubViewport/Ground.get_node("Sprite2D").texture.get_height()
	gameover_screen.tryagain.connect(code_ui.show)
	code_ui.run.connect(new_game)
	timer.timeout.connect(generate_obs)


func new_game():
	
	score = 0
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
	if camera.global_position.x - $SubViewport/Ground.global_position.x > screen_size.x * 1.5:
		$SubViewport/Ground.global_position.x += screen_size.x
		

func generate_obs():
	#generate ground obstacles
	var rand = randf()
	
	var obs_type = obstacle_types.pick_random()
	var obs
	var max_obs = difficulty + 1
	
	var obs_count:int=(randi() % max_obs + 1)
	
	for i in range(obs_count):
		obs = obs_type.instantiate()
		var obs_height = obs.get_node("Sprite2D").texture.get_height()
		var obs_scale = obs.get_node("Sprite2D").scale
		var obs_x : int = screen_size.x + score + 100 + (i * 100)
		var obs_y : int = screen_size.y - ground_height - (obs_height * obs_scale.y / 2) + 25
		last_obs = obs
		add_obs(obs, obs_x, obs_y)
		
	
	
	#additionally random chance to spawn a bird
	if (randi() % MAX_DIFFICULTY+1) <= difficulty:
			#generate bird obstacles
			obs = drone_scene.instantiate()
			var obs_x : int = screen_size.x + score + 100
			var obs_y : int = bird_heights.pick_random()
			add_obs(obs, obs_x, obs_y)
	
	var next_spawn:float = .25 + randf() * max(0,4-speed*0.05) + obs_count*0.1
	print(next_spawn)
	
	
	
func add_obs(obs:Obstacle, x, y):
	obs.position = Vector2i(x, y)
	obs.area_entered.connect(hit_obs)
	$SubViewport.add_child(obs)


func hit_obs(body):
	#return  
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
	

	
	timer.stop()
	
	await get_tree().create_timer(.8).timeout
	$GameOver.show()
