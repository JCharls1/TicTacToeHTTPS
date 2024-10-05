extends Node

var a
#func _ready():

func request(data_to_send):
	$HTTPRequest.request_completed.connect(_on_request_completed)
	print(1)
	#$HTTPRequest.request("https://test-server-1-git-main-jcharls1s-projects.vercel.app/api/greet")
	var url = "https://test-server-1-git-main-jcharls1s-projects.vercel.app/api/board"
	#var data_to_send = {
		#"0": "X",
		#"1": "X",
		#"2": "O",
		#"3": "O",
		#"4": "O",
		#"5": "X",
		#"6": "X",
		#"7": "O",
		#"8": " "
	#}
	var json = JSON.stringify(data_to_send)
	var headers = ["Content-Type: application/json"]
	$HTTPRequest.request(url, headers, HTTPClient.METHOD_POST, json)
func _on_request_completed(result, response_code, headers, body):
	print(2)
	var json = JSON.parse_string(body.get_string_from_utf8())
	print(json)
	a = json
	return json

func get_res():
	return a
#func _on_request_completed(result, response_code, body):
	#var url = "https://test-server-1-git-main-jcharls1s-projects.vercel.app/api/board"
	#var data_to_send = {
		#"0": "X",
		#"1": "X",
		#"2": "O",
		#"3": "O",
		#"4": "O",
		#"5": "X",
		#"6": "X",
		#"7": "O",
		#"8": " "
	#}
	#var json = JSON.stringify(data_to_send)
	#var headers = ["Content-Type: application/json"]
	#$HTTPRequest.request(url, headers, HTTPClient.METHOD_POST, json)
	#
	#var tae = JSON.parse_string(body.get_string_from_utf8())
	##print(tae)
