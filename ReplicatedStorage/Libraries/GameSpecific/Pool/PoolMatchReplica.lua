local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ReplicaController = require(ReplicatedStorage.Libraries.Modules.Madwork.ReplicaController)

local v = nil
local bindableEvent = Instance.new("BindableEvent")
local PoolMatchReplica = {
	["Changed"] = bindableEvent.Event,
	OnReplica = function(callback)
		local v2 = nil

		local function deliver() -- 1 equivalent call inferred from this helper
			local v3 = v

			if not v3 or v3 == v2 then
				return
			end

			v2 = v3

			task.spawn(callback, v3)
		end

		local eventConnection = bindableEvent.Event:Connect(deliver)
		deliver() -- inferred equivalent call
		return eventConnection
	end,
	Get = function()
		return v
	end,
	GetState = function()
		return v and v.Data and v.Data.poolMatch
	end,
	Wait = function(value: number?)
		local v2 = os.clock() + (value or 10)

		while not v and os.clock() < v2 do
			task.wait(0.05)
		end

		return v
	end
}

local v2 = false

local function adopt(object)
	if not object or object == v then
		return
	end

	v = object

	bindableEvent:Fire()

	object:AddCleanupTask(function()
		if v == object then
			v = nil
			bindableEvent:Fire()
		end
	end)
end

local function adoptExisting()
	local replicas = ReplicaController._replicas

	if type(replicas) ~= "table" then
		return
	end

	for _, replica in replicas do
		if replica.Class == "PoolMatch" then
			if not (replica and replica ~= v) then
				break
			end

			v = replica

			bindableEvent:Fire()

			replica:AddCleanupTask(function()
				if v == replica then
					v = nil
					bindableEvent:Fire()
				end
			end)
			break
		end
	end
end

function PoolMatchReplica.Init()
	if v2 or not Players.LocalPlayer then
		return
	end

	v2 = true

	ReplicaController.ReplicaOfClassCreated("PoolMatch", adopt)

	adoptExisting()

	if not ReplicaController.InitialDataReceived then
		ReplicaController.InitialDataReceivedSignal:Connect(adoptExisting)
	end

	ReplicaController.RequestData()
end

return PoolMatchReplica