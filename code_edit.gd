@tool
extends CodeEdit
class_name Gameboard

@onready var button: Button = $"../HBoxContainer/Button"

const red_col_keywords:Array[String] = [
	"true","false","var","func","in","as","not","is","class_name","extends"
]

const pink_col_keywords:Array[String] = [
	"return","pass","for"
]


func _ready() -> void:
	add_comment_delimiter("#","",true)
	text_changed.connect(request_code_completion)
	
	for key in red_col_keywords:
		(syntax_highlighter as CodeHighlighter).add_keyword_color(key,Color(1.0, 0.439, 0.522))
	
	for key in pink_col_keywords:
		(syntax_highlighter as CodeHighlighter).add_keyword_color(key,Color(0.976, 0.537, 0.78))
	

	for key in pink_col_keywords:
		(syntax_highlighter as CodeHighlighter).add_keyword_color(key,Color(0.976, 0.537, 0.78))
	
	(syntax_highlighter as CodeHighlighter).add_color_region('"','"',Color(0.976, 0.91, 0.62))
	
func code_request_code_completion():
	update_code_completion_options(true)


func _request_code_completion(force: bool) -> void:
	
	var word := get_current_word()
	if word.is_empty() or word.begins_with('"') or word.begins_with("_"):return
	
	for method in CPU.new(Cubot.new()).get_method_list():
		var func_name :String= method.name
			
		if not func_name.begins_with(word) or func_name.begins_with("_"): continue
		add_code_completion_option(KIND_FUNCTION,func_name,func_name+"()")
	
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
