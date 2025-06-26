extends CodeEdit
class_name Gameboard

@onready  var button: Button = $"../Button"






func _ready() -> void:
	add_comment_delimiter("/*","*/")
	add_comment_delimiter("//","",true)
	set_code_hint("ti")
	text_changed.connect(request_code_completion)
	
	#syntax_highlighter.

func _request_code_completion(force: bool) -> void:
	
	var word := get_text_for_code_completion() 
	
	for method in CPU.new(Cubot.new()).get_method_list():
		var func_name :String= method.name
		
		
		if word in func_name : continue
		add_code_completion_option(KIND_FUNCTION,method.name,method.name)
	
	update_code_completion_options(force)
