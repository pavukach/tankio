class_name ByteWriter

var _data: PackedByteArray

func append_int(value: int, bytes: int) -> void:
	for i in range(bytes):
		_data.append(value % 256)
		value >>= 8

func append(data: PackedByteArray) -> void:
	_data.append_array(data)

func get_data() -> PackedByteArray:
	return _data
