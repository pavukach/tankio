class_name ClientText
extends RichTextLabel

static var instance: ClientText

func _ready():
	instance = self

static func send_text(input: String, target_peer: int = 0):
	if not instance:
		print("instance null")
		return
	if not instance.multiplayer.is_server():
		return
	if target_peer == 0:
		instance.rpc("receive_text", input)
	else:
		instance.rpc_id(target_peer, "receive_text", input)

static func clear_text(target_peer: int = 0):
	var empty_text = ""
	if not instance.multiplayer.is_server():
		return
	if instance == null:
		return
	if target_peer == 0:
		instance.rpc("receive_text", empty_text)
	else:
		instance.rpc_id(target_peer, "receive_text", empty_text)

@rpc("reliable")
func receive_text(input: String):
	if input.is_empty():
		clear()
	else:
		append_text(input + "\n")
