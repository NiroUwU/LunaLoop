Changelog = {}

Changelog['v0.1'] = [[
Added commands: echo, hello, info, help, changelog, kiss, boop, hug, slap
]]

Changelog['v0.2'] = [[
Added Commands:
roll, flip

Fixed issues:
- Bot crash when hugging/slapping/kissing/booping/patting yourself in dms of the bot
- Bot crash when rolling die with one argument and no seperator
- Added pat command

Other:
- Commands are now caseinsensitive
- Prefixes can now be multiple strings long
- Added auto "git pull" request in start.sh script for automatic updates
]]

Changelog['v0.3'] = [[
Added command:
- convert (converts units of measurements)
]]

Changelog['v0.4'] = [[
Added commands:
- pickrandom (picks a random word from supplied arguments, split by spaces)
- ynm (ask a question and get a reply ranging from yes, no or maybe)
- checklove (ping two users and get their love value calculated based on their discord IDs)
- checktruth (provide a string of text after the command name and get the string's objective, inrefutable and correct truth value)

Changes:
- Help command is now more compact
- added a "Playing" status message
]]

return Changelog
