class_name NetConfig

## How far behind the newest received server tick a client starts rendering,
## before latency has been measured.
const INITIAL_INTERP_DELAY_TICKS := 6.0

## Delay held on top of measured latency, so that jitter of a tick or two
## still leaves a newer snapshot to interpolate toward.
const INTERP_DELAY_MARGIN_TICKS := 2.0
const MIN_INTERP_DELAY_TICKS := 2.0
const MAX_INTERP_DELAY_TICKS := 20.0

## The delay grows quickly, because too little of it leaves the history with
## nothing ahead of the playhead, and shrinks slowly, so that a brief quiet
## spell does not immediately give up the headroom.
const DELAY_GROW_RATE := 0.5
const DELAY_SHRINK_RATE := 0.03

## Client latency probe.
const PING_INTERVAL := 0.5
const PING_SMOOTHING := 0.2
const PING_SPIKE_SMOOTHING := 0.5
const PING_DECAY_SMOOTHING := 0.03

## Snapshots retained per variable. Has to span the interpolation delay with
## room left for late and reordered packets.
const SNAPSHOT_HISTORY := 32

## Fraction of the remaining offset error the playhead closes per tick.
const PLAYHEAD_CORRECTION := 0.1

## Offset error, in ticks, beyond which the playhead resyncs in one step
## instead of easing toward the target.
const PLAYHEAD_RESYNC_TICKS := 10.0

const IP_ADDRESS := "127.0.0.1"
const PORT := 4242
const MAX_CLIENTS := 4