class_name ByteReader

var _data: PackedByteArray
var _pos: int

func _init(data: PackedByteArray) -> void:
	_data = data

func get_int(bytes: int) -> int:
	var value := 0
	for i in range(bytes):
		value <<= 8
		value += _data[_pos]
		_pos += 1
	return value

func has_data() -> bool:
	return _pos < _data.size()
