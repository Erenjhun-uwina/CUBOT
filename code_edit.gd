extends CodeEdit
class_name Gameboard

@onready var button: Button = $"../HBoxContainer/Button"




func _ready() -> void:
	add_comment_delimiter("#","",true)
	text_changed.connect(request_code_completion)



func code_request_code_completion():
	update_code_completion_options(true)


func _request_code_completion(force: bool) -> void:
	
	var word := get_current_word()
	if word.is_empty():return
	
	for method in CPU.new(Cubot.new()).get_method_list():
		var func_name :String= method.name
			
		if not func_name.begins_with(word) : continue
		add_code_completion_option(KIND_FUNCTION,func_name,func_name)
	
	for prop in CPU.new(Cubot.new()).get_property_list():
		var prop_name :String= prop.name
			
		if not prop_name.begins_with(word) : continue
		add_code_completion_option(KIND_MEMBER,prop_name,prop_name)
	update_code_completion_options(force)

func get_current_word() -> String:
	var line := get_caret_line()
	var column := get_caret_column()
	
	var text := get_line(line).substr(0, column)

	var regex := RegEx.new()
	regex.compile(r"[a-zA-Z_][a-zA-Z_0-9]*$")

	var result := regex.search(text)
	return result.get_string() if result else ""
