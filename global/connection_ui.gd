class_name ConnectionUI
extends CanvasLayer

@onready var ip_input: LineEdit = %IPInput
@onready var port_input: LineEdit = %PortInput
@onready var connect_btn: Button = %ConnectBtn
@onready var status_label: Label = %StatusLabel
@onready var init_node: MultiplayerInit = %MultiplayerInit

func _ready() -> void:
	connect_btn.pressed.connect(_on_connect_pressed)

func _on_connect_pressed() -> void:
	connect_btn.disabled = true
	status_label.visible = true
	status_label.text = "Connecting..."
	var ip := ip_input.text.strip_edges()
	var port := int(port_input.text.strip_edges())
	if port <= 0:
		port = NetConfig.PORT
	if ip.is_empty():
		ip = NetConfig.IP_ADDRESS
	init_node.connect_to_server(ip, port)
