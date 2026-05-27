class_name TankSelector
extends VBoxContainer

signal tank_selected(index: int)

func build(spawner: TankSpawner) -> void:
	for i in spawner.tank_entries.size():
		var entry: TankEntry = spawner.tank_entries[i]
		var button := Button.new()
		button.text = entry.display_name
		button.pressed.connect(_on_button_pressed.bind(i))
		add_child(button)

func _on_button_pressed(index: int) -> void:
	tank_selected.emit(index)
