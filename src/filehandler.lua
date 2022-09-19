filehandler = {}

function filehandler.read(file)
	local f = io.open(file, "r")
	if f == nil then
		local err = string.format("File '%s' could not be read! Exiting. :(", file)
		bot.debug(err)
		return nil
	end

	local output = f:read("*a")
	f:close()

	return output
end

return filehandler
