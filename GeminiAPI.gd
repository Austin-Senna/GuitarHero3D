extends Node

const API_URL = "https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent"
var api_key = "AIzaSyB7zLqPMAChi8sq-X4GsH9TOZzRjXAglvo"

signal response_received(response_text: String)
signal error_occurred(error_message: String)

var http_request: HTTPRequest

func _ready():
	http_request = HTTPRequest.new()
	add_child(http_request)
	http_request.request_completed.connect(_on_request_completed)

func analyze_performance(analysis_data: Dictionary):
	var prompt = create_analysis_prompt(analysis_data)
	send_prompt(prompt)

func create_analysis_prompt(data: Dictionary) -> String:
	return """You are an expert Guitar Hero coach analyzing a player's performance. Here's their data:

OVERALL PERFORMANCE:
- Total Notes: %d
- Correct Hits: %d (%.1f%% accuracy)
- Wrong Keys: %d
- Missed Notes: %d
- Extra Presses: %d

KEY-SPECIFIC PERFORMANCE:
Q key: %d/%d correct (%.1f%% accuracy), %d missed, %d wrong
W key: %d/%d correct (%.1f%% accuracy), %d missed, %d wrong
E key: %d/%d correct (%.1f%% accuracy), %d missed, %d wrong
R key: %d/%d correct (%.1f%% accuracy), %d missed, %d wrong

Please provide:
1. The top 2-3 most critical issues in their performance
2. Specific practice exercises for each issue
3. A recommended training plan for the next session
4. Encouragement based on their strengths

Keep the response concise and actionable, formatted with clear sections.""" % [
		data.total_notes,
		data.correct_hits,
		data.accuracy,
		data.wrong_hits,
		data.missed_notes,
		data.extra_presses,
		data.key_errors.Q.total - data.key_errors.Q.missed - data.key_errors.Q.wrong,
		data.key_errors.Q.total,
		float(data.key_errors.Q.total - data.key_errors.Q.missed - data.key_errors.Q.wrong) / float(data.key_errors.Q.total) * 100.0 if data.key_errors.Q.total > 0 else 0.0,
		data.key_errors.Q.missed,
		data.key_errors.Q.wrong,
		# ... repeat for W, E, R keys ...
	]

func send_prompt(prompt: String):
	var headers = ["Content-Type: application/json"]
	var body = {
		"contents": [{
			"parts": [{"text": prompt}]
		}]
	}
	var json_body = JSON.stringify(body)
	var url = API_URL + "?key=" + api_key
	http_request.request(url, headers, HTTPClient.METHOD_POST, json_body)

func _on_request_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray):
	if result != HTTPRequest.RESULT_SUCCESS or response_code != 200:
		error_occurred.emit("API error")
		return
	
	var json = JSON.new()
	json.parse(body.get_string_from_utf8())
	var response_data = json.get_data()
	
	if response_data and "candidates" in response_data:
		var response_text = response_data.candidates[0].content.parts[0].text
		response_received.emit(response_text)
