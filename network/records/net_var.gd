class_name NetVar
extends RefCounted

var _value
var _type

func _init(p_value: Variant, p_type: ByteData.Type) -> void:
	_value = p_value
	_type = p_type

func get_type() -> ByteData.Type:
	return _type

func get_value() -> Variant:
	return _value

func set_value(p_value: Variant) -> void:
	_value = p_value
