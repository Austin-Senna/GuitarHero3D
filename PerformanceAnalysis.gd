extends Control

var gemini_api: Node
@onready var analysis_label = $VBoxContainer/AnalysisLabel

func _ready():
	visible = false
	
	# Initialize Gemini API
	gemini_api = load("res://GeminiAPI.gd").new()
	add_child(gemini_api)
	gemini_api.response_received.connect(_on_analysis_received)
	gemini_api.error_occurred.connect(_on_analysis_error)

func show_analysis():
	visible = true
	analysis_label.text = "Analyzing your performance..."
	
	# Get analysis data and send to Gemini
	var analysis_data = GameManager.key_logger.get_analysis_data()
	gemini_api.analyze_performance(analysis_data)

func _on_analysis_received(response: String):
	analysis_label.text = response

func _on_analysis_error(error: String):
	analysis_label.text = "Error analyzing performance: " + error
