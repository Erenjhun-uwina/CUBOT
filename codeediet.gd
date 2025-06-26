extends Control
@onready var code_edit: Gameboard = $VBoxContainer/CodeEdit


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_button_pressed() -> void:
	var runner:Runner =  get_parent().get_parent()
	runner.process_mode = Node.PROCESS_MODE_ALWAYS
	hide()
	
	var script = GDScript.new()
	var code:="extends CPU \n" + code_edit.text
	
	script.source_code = code
	script.reload(true)
	runner.cubot.cpu  = script.new(runner.cubot)
	
	
