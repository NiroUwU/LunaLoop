filehandler = {}

function filehandler.read(file)
	local f = io.open(file, "r")
	if f == nil then
		return string.format("File '%s' could not be read! Exiting. :(", file)
	end

	local output = f:read("*a")
	f:close()

	return output
end

return filehandler
