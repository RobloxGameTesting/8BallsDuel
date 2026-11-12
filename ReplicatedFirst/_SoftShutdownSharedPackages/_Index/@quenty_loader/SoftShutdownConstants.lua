local loader = require(script.Parent.loader)
return loader.load(script)("Table").readonly({
	IS_SOFT_SHUTDOWN_LOBBY_ATTRIBUTE = "IsSoftShutdownLobby",
	IS_SOFT_SHUTDOWN_UPDATING_ATTRIBUTE = "IsSoftshutdownRebootingServers"
})