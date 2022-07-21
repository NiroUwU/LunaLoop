filehandler = {}

function filehandler.read(file)
	file:open(file, "r")
	local output = file:read("*a")
	file:close()

	return output
end

return filehandler
