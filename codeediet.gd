extends Control

@export var runner:Runner
@onready var code_edit: Gameboard = $PanelContainer/VBoxContainer/CodeEdit

signal run

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	get_parent().show()
	visibility_changed.connect(func():
		
		if code_edit.text.is_empty():
			code_edit.text = "extends CPU \n
			func start():\n
			\tpass\n
			func loop(delta):\n
			\tpass
			"
			
		if not visible:
			get_tree().paused = false
			return
		get_tree().paused = true

		)


func _on_button_pressed() -> void:
	
	var script = GDScript.new()
	var code:= code_edit.text
	script.source_code = code
	#print(code)
	script.reload(true)
	runner.cubot.cpu  = script.new(runner.cubot)
	hide()
	run.emit()
	print("pff")
	
