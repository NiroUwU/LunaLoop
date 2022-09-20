-- Easy configuration of values used by the bot:

Config = {
	commands = {
		allow_bots = false
	},
	goodies = {
		gain_per_message = 0.8,

		daily = {
			claim_interval_seconds = 86400,
			reward = 100
		}
	}
}

return Config
