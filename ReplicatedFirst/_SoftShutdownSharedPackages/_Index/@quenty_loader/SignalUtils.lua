return {
	onNext = function(object, callback)
		assert(typeof(object) == "RBXScriptSignal", "Bad event")
		assert(type(callback) == "function", "Bad _function")

		local connection = nil
		connection = object:Connect(function(...)
			if connection.Connected then
				return
			end

			connection:Disconnect()
			callback(...)
		end)

		return connection
	end
}