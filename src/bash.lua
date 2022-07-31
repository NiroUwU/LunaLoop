local bash = {}
local function run(cmd, ...)
	os.execute(string.format(cmd, ...))
end

function bash.execute(fileOutput, cmd, ...)
	-- Make a temporary cache directory:
	run('[ ! -d "%s" ] && mkdir %s', Filesystem.cache, Filesystem.cache)

	-- Run command and write stout to file:
	local fullFilePath = string.format("%s/%s.tmp", Filesystem.cache, fileOutput)
	cmd = string.format(cmd, ...)
	run("%s > %s", cmd, fullFilePath)

	local result = filehandler.read(fullFilePath)

	-- Clear cached file, if setting enabled:
	if Filesystem.autoRemoveCache then
		run('[ -f "%s" ] && rm %s', fullFilePath, fullFilePath)
	end

	return result
end

return bash
