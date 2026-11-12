local ReplicatedFirst = game:GetService("ReplicatedFirst")

local softShutdownClientPackages = ReplicatedFirst:WaitForChild("_SoftShutdownClientPackages")

local SoftShutdownServiceClient = require(softShutdownClientPackages.SoftShutdownServiceClient)
local ServiceBag = require(softShutdownClientPackages.ServiceBag)
local v = ServiceBag.new()

v:GetService(SoftShutdownServiceClient)

v:Init()
v:Start()