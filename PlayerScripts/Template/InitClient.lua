local ReplicatedStorage = game:GetService("ReplicatedStorage")

local function BootModule(instance)
	tick()
	local success, result = pcall(require, instance)

	if not success then
		warn("[BOOT] Failed to require:", instance:GetFullName())
		return
	end

	tick()

	if typeof(result) == "table" then
		local init = result.Init

		if typeof(init) == "function" then
			local success2, result2 = pcall(init, result)

			if not success2 then
				warn("[BOOT] Init failed:", instance:GetFullName(), result2)
			end
		end
	end

	tick()
end

for _, v in {
	ReplicatedStorage.Libraries.Modules.Mouselock,
	ReplicatedStorage.Libraries.Modules.Scheduler,
	ReplicatedStorage.Libraries.Modules.Sales,
	ReplicatedStorage.Libraries.Modules.RagdollHandler,
	ReplicatedStorage.Libraries.Helpers.CameraHelper,
	ReplicatedStorage.Libraries.Modules.AdminController,
	ReplicatedStorage.Libraries.Modules.Events,
	ReplicatedStorage.Libraries.Helpers.TeleportHelper,
	ReplicatedStorage.Libraries.Modules.ItemDrops,
	ReplicatedStorage.Libraries.Modules.PackOpenHandler,
	ReplicatedStorage.Libraries.Modules.HealthHandler,
	ReplicatedStorage.Libraries.Modules.MechanicHandler,
	ReplicatedStorage.Libraries.Modules.CharacterUpdate,
	ReplicatedStorage.Libraries.Helpers.ChatHelper,
	ReplicatedStorage.Libraries.Helpers.FriendHelper,
	ReplicatedStorage.Libraries.Modules.MoneyPad,
	ReplicatedStorage.Libraries.GameSpecific.Attacks.Swings.SwingNetworkHandler,
	ReplicatedStorage.Libraries.GameSpecific.Attacks.Bullets.BulletNetworkHandler,
	ReplicatedStorage.Libraries.GameSpecific.Attacks.Abilities.AbilityNetworkHandler,
	ReplicatedStorage.Libraries.GameSpecific.Attacks.Throwables.ThrowableNetworkHandler,
	ReplicatedStorage.Libraries.GameSpecific.Attacks.Explosions.ExplosionNetworkHandler,
	ReplicatedStorage.Libraries.GameSpecific.Attacks.Areas.AreaNetworkHandler,
	ReplicatedStorage.Libraries.Modules.Toolbar,
	ReplicatedStorage.Libraries.GameSpecific.Tools.WeaponNetworkHandler,
	ReplicatedStorage.Libraries.GameSpecific.Enemies.EnemyNetworkHandler,
	ReplicatedStorage.Libraries.Modules.Spectate,
	ReplicatedStorage.Libraries.Modules.CharacterUpdate,
	ReplicatedStorage.Libraries.Modules.Gamepasses,
	ReplicatedStorage.Libraries.GameSpecific.Pets.PetNetworkHandler
} do
	BootModule(v)
end