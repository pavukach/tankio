class_name NetHost
extends NetObject

## A network endpoint that is not a replicated scene object.
##
## Hosts have an id and methods so packets can be addressed to them, but no
## replicated variables. Where a NetNode is handed its id by the server that
## spawned it, a host claims its own, so every peer has to claim the same id
## for the same host.

func claim_id(id: int) -> void:
	network_id = id
	NetManager.network.add_entity(network_id, self)