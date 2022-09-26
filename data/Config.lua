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
		},
		lottery = {
			ticket_cost = 10,
			tax = 0.05
		}
	}
}

return Config
