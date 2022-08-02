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

Changelog['v0.4.1'] = [[
Changes:
- convert command now only displays list of units when executing `convert list`, not cluttering up your full screen :)
- more units added to the convert command
- info command with more information

Fixed Issues:
- Bot crash when executing checklove command with the same person as both arguments
- convert command value correction
- spelling mistakes

Added Functionality:
- Bot can now run shell scripts through commands, giving more interaction with the host system
]]

Changelog['v1.0.0'] = [[
Changes:
- Commands have been migrated to be sent as embeds
]]

return Changelog
