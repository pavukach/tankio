class_name OrderedIndexBank
extends RefCounted

var _next_index := 0
var _free_indices: Array[int] = []

func get_index() -> int:
	if _free_indices.size() > 0:
		return _free_indices.pop_back()
	var index := _next_index
	_next_index += 1
	return index

func get_consecutive(count: int) -> int:
	var cur_count := 0
	var last := 0
	var run_start := 0
	for i in range(_free_indices.size()):
		var index = _free_indices[i]
		if cur_count > 0 and last - 1 == index:
			cur_count += 1
		else:
			cur_count = 1
			run_start = i
		last = index
		if cur_count == count:
			for j in range(count):
				_free_indices.remove_at(run_start)
			return index
	# allocate indices
	_next_index += count
	return _next_index - count

func free_index(index: int) -> void:
	var place = _free_indices.bsearch_custom(index, func(a, b): return a > b)
	_free_indices.insert(place, index)
	while _free_indices.size() > 0 and _free_indices[0] + 1 == _next_index:
		_next_index -= 1
		_free_indices.pop_front()
