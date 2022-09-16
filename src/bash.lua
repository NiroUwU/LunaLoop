local bash = {}
local tempBlock = false
local function run(cmd, ...)
	os.execute(string.format(cmd, ...))
end
function bash.ignoreAutoremoveCache()
	bot.debug("Bash autoremove has been temporarily blocked!")
	tempBlock = true
end

function bash.execute(fileOutput, cmd, ...)
	-- Make a temporary cache directory:
	run('[ ! -d "%s" ] && mkdir %s', Filesystem.cache, Filesystem.cache)

	-- Run command and write stout to file:
	local fullFilePath = string.format("%s/%s", Filesystem.cache, fileOutput)
	cmd = string.format(cmd, ...)
	run("%s > %s", cmd, fullFilePath)

	local result = filehandler.read(fullFilePath)

	-- Clear cached file, if setting enabled:
	if Filesystem.autoRemoveCache or not tempBlock then
		run('[ -f "%s" ] && rm %s', fullFilePath, fullFilePath)
	end

	-- Revert temp block:
	if tempBlock then
		tempBlock = false
	end

	return result
end

function bash.mkdir(dir, ...)
	if not dir then return end
	dir = string.format(dir, ...)
	run("mkdir %s", dir)
end

function bash.touch(file, content)
	if not file then return end
	run("touch %s", file)
	if content ~= nil then
		run("echo '%s' > %s", tostring(content), file)
	end
end

return bash
