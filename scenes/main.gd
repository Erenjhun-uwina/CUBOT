extends Node
class_name  Runner

#preload obstacles
var stump_scene = preload("res://scenes/obstacles/scene/stump.tscn")
var rock_scene = preload("res://scenes/obstacles/scene/rock.tscn")
var barrel_scene = preload("res://scenes/obstacles/scene/barrel.tscn")
var drone_scene = preload("res://scenes/obstacles/scene/drone.tscn")
var obstacle_types := [stump_scene, rock_scene, barrel_scene]
var obstacles : Array[Obstacle]
var bird_heights := [200, 390]

#game variables
var difficulty
const MAX_DIFFICULTY : int = 2
var score : int
const SCORE_MODIFIER : int = 10
var high_score : int
var speed : float
const START_SPEED : float = 10.0
const MAX_SPEED : int = 25
const SPEED_MODIFIER : int = 5000
var screen_size : Vector2i
var ground_height : int
var last_obs

@export var cubot:Cubot
@onready var gameover_screen: Gameover_screen = $GameOver
@onready var code_ui = $HUD2/Code_UI
@onready var camera: Camera2D = $cubot/Camera2D
@onready var corpse: Corpse = $corpse

# Called when the node enters the scene tree for the first time.
func _ready():
	get_tree().paused = true
	
	screen_size = get_window().size
	ground_height = $Ground.get_node("Sprite2D").texture.get_height()
	gameover_screen.tryagain.connect(code_ui.show)
	code_ui.run.connect(new_game)


func new_game():
	score = 0
	show_score()
	get_tree().paused = false
	difficulty = 0
	
	#delete all obstacles
	for obs in obstacles:
		obs.queue_free()
	obstacles.clear()
	
	#reset the nodes
	cubot.respawn()
	corpse.disable()
	$Ground.position = Vector2i(0, 0)
	set_process(true)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	cubot.cpu.clear_requests()
	

	
	#speed up and adjust difficulty
	speed = START_SPEED + score / SPEED_MODIFIER
	if speed > MAX_SPEED:
		speed = MAX_SPEED
	adjust_difficulty()
	
	#generate obstacles
	generate_obs()
	
	#move dino and camera
	cubot.position.x += speed
	
	#update score
	score += speed
	show_score()
	
	#update ground position
	if camera.global_position.x - $Ground.global_position.x > screen_size.x * 1.5:
		$Ground.global_position.x += screen_size.x
		
	#remove obstacles that have gone off screen
	for obs:Obstacle  in obstacles:
		if obs.position.x < (camera.position.x - screen_size.x):
			remove_obs(obs)


func generate_obs():
	#generate ground obstacles
	if obstacles.is_empty() or last_obs.position.x < score + randi_range(300, 500):
		var obs_type = obstacle_types[randi() % obstacle_types.size()]
		var obs
		var max_obs = difficulty + 1
		for i in range(randi() % max_obs + 1):
			obs = obs_type.instantiate()
			var obs_height = obs.get_node("Sprite2D").texture.get_height()
			var obs_scale = obs.get_node("Sprite2D").scale
			var obs_x : int = screen_size.x + score + 100 + (i * 100)
			var obs_y : int = screen_size.y - ground_height - (obs_height * obs_scale.y / 2) + 25
			last_obs = obs
			add_obs(obs, obs_x, obs_y)
		#additionally random chance to spawn a bird
		if difficulty == MAX_DIFFICULTY:
			if (randi() % 2) == 0:
				#generate bird obstacles
				obs = drone_scene.instantiate()
				var obs_x : int = screen_size.x + score + 100
				var obs_y : int = bird_heights[randi() % bird_heights.size()]
				add_obs(obs, obs_x, obs_y)

func add_obs(obs:Obstacle, x, y):
	obs.position = Vector2i(x, y)
	obs.area_entered.connect(hit_obs)
	add_child(obs)
	obstacles.append(obs)

func remove_obs(obs:Obstacle):
	obs.queue_free()
	obstacles.erase(obs)

func hit_obs(body):
	cubot.die()
	corpse.spawn(cubot.global_position)
	game_over()

func show_score():
	$HUD.get_node("ScoreLabel").text = "SCORE: " + str(score / SCORE_MODIFIER)

func check_high_score():
	if score > high_score:
		high_score = score
		$HUD.get_node("HighScoreLabel").text = "HIGH SCORE: " + str(high_score / SCORE_MODIFIER)

func adjust_difficulty():
	difficulty = score / SPEED_MODIFIER
	if difficulty > MAX_DIFFICULTY:
		difficulty = MAX_DIFFICULTY

func game_over():
	check_high_score()
	set_process(false)
	await get_tree().create_timer(.8).timeout
	$GameOver.show()
