class_name ConnectionUI
extends CanvasLayer

@onready var ip_input: LineEdit = %IPInput
@onready var port_input: LineEdit = %PortInput
@onready var protocol_option: OptionButton = %ProtocolOption
@onready var connect_btn: Button = %ConnectBtn
@onready var status_label: Label = %StatusLabel
@onready var init_node: NetworkInit = %NetworkInit

func _ready() -> void:
	connect_btn.pressed.connect(_on_connect_pressed)
	LocalBus.connected.connect(_on_connected)
	_prefill_defaults()
	if OS.get_environment("TANKIO_AUTOCONNECT") == "1":
		_on_connect_pressed.call_deferred()

func _resolve_defaults() -> Dictionary:
	var host := OS.get_environment("TANKIO_HOST")
	var port := -1
	var proto := OS.get_environment("TANKIO_PROTO")

	var env_port := OS.get_environment("TANKIO_PORT")
	if not env_port.is_empty():
		port = int(env_port)

	if host.is_empty():
		host = NetConfig.IP_ADDRESS
	if port < 0:
		port = NetConfig.PORT
	if proto.is_empty():
		proto = "ws"
	return {"host": host, "port": port, "proto": proto}

func _prefill_defaults() -> void:
	var d := _resolve_defaults()
	ip_input.text = d.host
	port_input.text = str(d.port)
	for i in protocol_option.item_count:
		if protocol_option.get_item_text(i) == d.proto:
			protocol_option.selected = i
			break

func _on_connect_pressed() -> void:
	connect_btn.disabled = true
	status_label.visible = true
	status_label.text = "Connecting..."
	var ip := ip_input.text.strip_edges()
	var port := int(port_input.text.strip_edges())
	var protocol := protocol_option.get_item_text(protocol_option.selected)
	if port <= 0:
		port = NetConfig.PORT
	if ip.is_empty():
		ip = NetConfig.IP_ADDRESS
	init_node.connect_to_server(ip, port, protocol)

func _on_connected() -> void:
	hide()