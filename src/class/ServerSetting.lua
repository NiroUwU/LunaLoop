ServerSetting = {}

ServerSetting.list = {}

ServerSetting.default = {
	custom_prefix = nil,
	disabled_commands = {},

	-- Log channels:
	log_join_leave = nil,
	log_member_update = nil,
	log_messages = nil
}

-- @param id Server ID for updating one specific or nil to update all
function ServerSetting:update(serverid)
	-- Update function:
	local function update(id)
		-- Check if settings file does exist, if not then create:
		local path_file = string.format("servers/%s/settings.json", id)
		local file = io.open(path_file, "r")
		if not file then
			bash.mkdir("servers/%s", id)
			bash.touch(path_file, "[]")
		else
			file:close()
		end

		-- Import all settings values:
		local settings = {
			default = ServerSetting.default,
			json = jsonfile.import(path_file),
			export = {}
		}

		-- Overwrite default with custom values:
		for i, v in pairs(settings.default) do
			if v ~= nil then settings.export[i] = v end
		end

		-- Write to file and seve to memory:
		jsonfile.export(path_file, settings.export)
		ServerSetting.list[id] = settings.export
	end

	-- Update one server or all of them:
	if serverid then
		update(serverid)
	else
		for _,v in pairs(ServerSetting.list) do update(v) end
	end
end

return ServerSetting
