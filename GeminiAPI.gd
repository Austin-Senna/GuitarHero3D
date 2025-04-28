extends Node

const API_URL = "https://generativelanguage.googleapis.com/v1/models/gemini-1.5-flash:generateContent"
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
	# Calculate accuracy for each key to avoid division by zero
	var q_total = data.key_errors.Q.total
	var q_correct = q_total - data.key_errors.Q.missed - data.key_errors.Q.wrong
	var q_accuracy = (float(q_correct) / float(q_total) * 100.0) if q_total > 0 else 0.0
	
	var w_total = data.key_errors.W.total
	var w_correct = w_total - data.key_errors.W.missed - data.key_errors.W.wrong
	var w_accuracy = (float(w_correct) / float(w_total) * 100.0) if w_total > 0 else 0.0
	
	var e_total = data.key_errors.E.total
	var e_correct = e_total - data.key_errors.E.missed - data.key_errors.E.wrong
	var e_accuracy = (float(e_correct) / float(e_total) * 100.0) if e_total > 0 else 0.0
	
	var r_total = data.key_errors.R.total
	var r_correct = r_total - data.key_errors.R.missed - data.key_errors.R.wrong
	var r_accuracy = (float(r_correct) / float(r_total) * 100.0) if r_total > 0 else 0.0
	
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
		# Q key data
		q_correct,
		q_total,
		q_accuracy,
		data.key_errors.Q.missed,
		data.key_errors.Q.wrong,
		# W key data
		w_correct,
		w_total,
		w_accuracy,
		data.key_errors.W.missed,
		data.key_errors.W.wrong,
		# E key data
		e_correct,
		e_total,
		e_accuracy,
		data.key_errors.E.missed,
		data.key_errors.E.wrong,
		# R key data
		r_correct,
		r_total,
		r_accuracy,
		data.key_errors.R.missed,
		data.key_errors.R.wrong
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
	print("API response received - Result: ", result, " Code: ", response_code)
	if result != HTTPRequest.RESULT_SUCCESS or response_code != 200:
		error_occurred.emit("API error")
		return
	
	if response_code != 200:
		var error_text = body.get_string_from_utf8()
		print("API error: ", error_text)
		error_occurred.emit("API error with response code: " + str(response_code) + "\n" + error_text)
		return
	
	var json = JSON.new()
	json.parse(body.get_string_from_utf8())
	var response_data = json.get_data()
	
	if response_data and "candidates" in response_data:
		var response_text = response_data.candidates[0].content.parts[0].text
		response_received.emit(response_text)
