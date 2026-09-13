class_name NetInterp
extends RefCounted

## Blend functions for NetVar. Each receives the two snapshots bracketing the
## interpolation playhead and the 0..1 position of the playhead between them.

static func linear(from: Variant, to: Variant, weight: float) -> Variant:
	return lerpf(from, to, weight)


static func angle(from: Variant, to: Variant, weight: float) -> Variant:
	return lerp_angle(from, to, weight)


## Holds the older snapshot until the playhead reaches the newer one, for
## values that step rather than move.
static func hold(from: Variant, _to: Variant, _weight: float) -> Variant:
	return from
