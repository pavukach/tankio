class_name ClientText
extends Node

static var instance: ClientText
static var debug_label: RichTextLabel

func _ready():
	instance = self
	debug_label = get_node("../DebugText")

static func send_text(text: String, target_peer: int = 0):
	if not instance:
		print("instance null")
		return
	if not instance.multiplayer.is_server():
		return
	if target_peer == 0:
		instance.rpc("receive_text", text)
	else:
		instance.rpc_id(target_peer, "receive_text", text)

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
func receive_text(text: String):
	if debug_label == null:
		return
	if text.is_empty():
		debug_label.clear()
	else:
		debug_label.append_text(text + "\n")
