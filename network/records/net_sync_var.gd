class_name NetSyncVar
extends NetVar

var _initial
signal changed

func _init(p_value: Variant, p_type: ByteData.Type) -> void:
	super(p_value, p_type)
	_initial = p_value

func set_value(p_value: Variant) -> void:
	_value = p_value
	changed.emit()

func is_initial() -> bool:
	return _value == _initial
