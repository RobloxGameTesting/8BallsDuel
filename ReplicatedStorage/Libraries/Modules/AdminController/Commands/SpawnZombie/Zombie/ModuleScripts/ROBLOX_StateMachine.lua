return {
	new = function()
		local v = {}
		v.WaitTime = 0.2
		v.CurrentState = nil

		function v.SwitchState(currentState)
			if v.CurrentState then
				v.CurrentState.Stop()
			end

			v.CurrentState = currentState

			if currentState then
				currentState.Start()
			end
		end

		function v.NewState()
			local v2 = {}
			v2.Name = ""
			v2.Conditions = {}
			v2.isRunning = false

			function v2.Action() end
			function v2.Run()
				v2.isRunning = true

				while v2.isRunning do
					for _, condition in pairs(v2.Conditions) do
						if condition.Evaluate() then
							v.SwitchState(condition.TransitionState)
							return
						end
					end

					v2.Action()
					wait(v.WaitTime)
				end
			end
			function v2.Init() end
			function v2.Start()
				v2.Init()
				local thread = coroutine.create(v2.Run)
				coroutine.resume(thread)
			end
			function v2.Stop()
				v2.isRunning = false
			end
			return v2
		end

		function v.NewCondition()
			return {
				Name = "",
				Evaluate = function(): boolean
					print("replace me")
					return false
				end,
				TransitionState = {}
			}
		end

		return v
	end
}