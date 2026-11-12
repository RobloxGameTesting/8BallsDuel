local loader = require(script.Parent.loader)
local loaded = loader.load(script)

local v = loaded("Observable")
local v2 = loaded("Maid")
local v3 = loaded("Rx")
local v4 = loaded("BasicPane")
local v5 = loaded("Brio")

local BasicPaneUtils = {}

function BasicPaneUtils.observeVisible(object)
	assert(v4.isBasicPane(object), "Bad BasicPane")

	return v.new(function(object2)
		local maid = v2.new()

		maid:GiveTask(object.VisibleChanged:Connect(function(p)
			object2:Fire(p)
		end))
		object2:Fire(object:IsVisible())

		return maid
	end)
end

function BasicPaneUtils.whenVisibleBrio(callback)
	return function(object)
		return v.new(function(object2)
			local maid = v2.new()

			local pane = nil

			local function ensurePane()
				if pane then
					return pane
				end

				local maid2 = v2.new()

				local v6 = callback(maid2)
				assert(v4.isBasicPane(v6), "Bad BasicPane")
				maid2:GiveTask(v6)

				local v7 = v5.new(v6.Gui)
				maid2:GiveTask(v7)

				pane = v6
				maid:GiveTask(function()
					if pane == v6 then
						pane = nil
					end
				end)

				maid._currentPaneMaid = maid2
				object2:Fire(v7)

				return pane
			end

			maid:GiveTask(object:Subscribe(function(p)
				if p then
					maid._hideTask = nil
					ensurePane():Show()
				elseif pane and pane:IsVisible() then
					pane:Hide()
					maid._hideTask = task.delay(1, function()
						pane = nil
						maid._currentPaneMaid = nil
					end)
				end
			end))

			return maid
		end)
	end
end

function BasicPaneUtils.observePercentVisible(p)
	assert(v4.isBasicPane(p), "Bad BasicPane")

	return BasicPaneUtils.observeVisible(p):Pipe({
		v3.map(function(p2): number
			return if p2 then 1 else 0
		end),
		v3.startWith({ 0 })
	})
end

BasicPaneUtils.toTransparency = v3.map(function(p)
	return 1 - p
end)

function BasicPaneUtils.observeShow(p)
	return BasicPaneUtils.observeVisible(p):Pipe({ v3.where(function(p2)
			return p2
		end) })
end

return BasicPaneUtils