class_name Projectile
extends Node2D

const METHOD_HIT_EFFECT := 2
const FORWARD_OFFSET := PI / 2

var _velocity := Vector2.ZERO
var _lifetime := 5.0
var _lifetime_timer := 0.0
var _previous_position := Vector2.ZERO
var _despawning := false
var _hit_handled := false

var net: NetNode
var _rot: NetVar

@export var profile: ProjectileProfile

@onready var hitbox := $Hitbox


func _ready() -> void:
	net = owner as NetNode
	_rot = NetVar.new(rotation, ByteData.Type.FLOAT, NetInterp.angle)
	net.register_var(_rot)
	net.register_initial_var(_rot)
	net.register_event(
		Effects.net_hit,
		[ByteData.Type.FLOAT, ByteData.Type.FLOAT, ByteData.Type.BYTE],
		true,
	)
	hitbox.body_shape_entered.connect(_handle_body_collision)
	if not NetManager.network.is_server():
		hitbox.monitoring = false
		hitbox.monitorable = false


func _physics_process(delta: float) -> void:
	if not NetManager.network.is_server():
		rotation = _rot.get_value()
		return
	_previous_position = net.global_position
	_lifetime_timer += delta
	if _lifetime_timer >= _lifetime:
		_request_despawn()
		return
	net.global_position += _velocity * delta


func setup(
	from_pos: Vector2,
	angle: float,
	p_owner_id: int,
) -> void:
	net.global_position = from_pos
	net.owner_id = p_owner_id
	_rot.set_value(angle)
	rotation = angle
	_velocity = Vector2.from_angle(angle - FORWARD_OFFSET) * profile.speed
	_lifetime = profile.lifetime
	_previous_position = from_pos


func _handle_body_collision(_body_rid: RID, body: Node2D, body_shape_index: int, _local_shape_index: int) -> void:
	if not NetManager.network.is_server() or _despawning or _hit_handled:
		return
	if body.is_in_group(str(net.owner_id)):
		return

	_hit_handled = true

	var result: Dictionary = HitResolver.resolve(
		body, body_shape_index,
		get_world_2d(), _velocity, profile, _lifetime_timer,
		_previous_position, net.global_position,
	)
	if not result.handled:
		return

	_despawning = true
	Effects.spawn_hit_effect(result.hit_pos, result.penetrated)
	NetManager.interest.send(
		net.network_id,
		METHOD_HIT_EFFECT,
		[result.hit_pos.x, result.hit_pos.y, 1 if result.penetrated else 0],
	)
	_request_despawn()


func _request_despawn() -> void:
	_despawning = true
	if NetManager.network.is_server():
		net.destroy()
