class_name NetTimeline
extends Node

## The shared clock replication is expressed in.
##
## The server counts physics ticks and stamps every outgoing packet with
## `server_tick()`. A client tracks the newest tick it has received and runs
## `playhead()` behind it by a delay sized from measured latency, so a variable
## sampled at the playhead normally has a snapshot on either side to
## interpolate between.

class Pending:
	var tick: int
	var action: Callable

	func _init(p_tick: int, p_action: Callable) -> void:
		tick = p_tick
		action = p_action


var _server_tick := 0
var _latest_tick := -1
var _playhead := -1.0
var _delay_ticks := NetConfig.INITIAL_INTERP_DELAY_TICKS
var _pending: Array[Pending] = []


func _ready() -> void:
	# Advance before anything else samples the playhead this tick.
	process_physics_priority = -128


func _physics_process(delta: float) -> void:
	if NetManager.network.is_server():
		_server_tick += 1
		return
	_advance(delta)
	_run_pending()


func server_tick() -> int:
	return _server_tick


## Client-side replication time, in server ticks. Negative until the first
## packet arrives.
func playhead() -> float:
	return _playhead


func observe_tick(tick: int) -> void:
	_latest_tick = maxi(_latest_tick, tick)


func interp_delay_ticks() -> float:
	return _delay_ticks


## Runs `action` once the playhead reaches `tick`, or immediately if it already
## has. Lets a client apply something at the point in replication time it
## happened rather than the moment its packet arrived.
func at_tick(tick: int, action: Callable) -> void:
	# A server renders its own authoritative state, with no delay to wait out.
	if NetManager.network.is_server() or _playhead >= tick:
		action.call()
		return
	_pending.append(Pending.new(tick, action))


func _run_pending() -> void:
	var i := 0
	while i < _pending.size():
		if _pending[i].tick > _playhead:
			i += 1
			continue
		var action := _pending[i].action
		_pending.remove_at(i)
		# The entity the action belongs to may have been freed while waiting.
		if action.is_valid():
			action.call()


## Runs the playhead on the local clock and eases it toward `_delay_ticks`
## behind the newest tick received, so jitter and clock drift are absorbed over
## several ticks. Driving it from packet arrival instead would step the
## playhead from one whole tick to the next, leaving nothing to interpolate.
func _advance(delta: float) -> void:
	if _latest_tick < 0:
		return
	_update_delay()
	var target := _latest_tick - _delay_ticks
	if _playhead < 0.0 or absf(target - _playhead) > NetConfig.PLAYHEAD_RESYNC_TICKS:
		_playhead = target
		return
	_playhead += delta * Engine.physics_ticks_per_second
	_playhead = lerpf(_playhead, target, NetConfig.PLAYHEAD_CORRECTION)


## Tracks measured latency, keeping the delay a margin above it so snapshots
## have arrived by the time the playhead reaches them.
func _update_delay() -> void:
	var target := clampf(
		NetManager.ping.latency() * Engine.physics_ticks_per_second
		+ NetConfig.INTERP_DELAY_MARGIN_TICKS,
		NetConfig.MIN_INTERP_DELAY_TICKS,
		NetConfig.MAX_INTERP_DELAY_TICKS,
	)
	var rate := (
		NetConfig.DELAY_GROW_RATE
		if target > _delay_ticks
		else NetConfig.DELAY_SHRINK_RATE
	)
	_delay_ticks = lerpf(_delay_ticks, target, rate)