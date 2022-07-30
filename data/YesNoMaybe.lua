-- This file contains the weight values for yes, no and maybe for the ynm command:
-- Notice: Numbers are not percentages!

YesNoMaybe = {}
YesNoMaybe.weight = {
	['yes']   = 5,
	['no']    = 5,
	['maybe'] = 2
}

-- This string will be fed through string.format(), %s is Message.author.mentionString (Ping)
YesNoMaybe.askMeSomethingPrompt = "I don't know, how about you ask me something, %s?"

-- This is the answer string, it will be fed through string.format() as well: (first is out, second is Message.author.mentionString)
YesNoMaybe.responsePrompt = "%s, %s."

return YesNoMaybe
