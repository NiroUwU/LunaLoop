Lottery = {}

function Lottery:buyTicket(Message, Caller, args, ...)
	local usage = "lotteryticket\nlotteryticket help\nlotteryticket [amount]"
	if Message.guild == nil then
		Message:reply { embed = getErrorMessageEmbed("User", "You have to run this command in a server.", usage)}
		return
	end

	-- Variables:
	local userinput = args[1]
	local cost = Config.goodies.lottery.ticket_cost

	-- Help Message:
	if tostring(userinput):lower() == "help" then
		local emb = {
			title = "Lottery Help Message",
			description = "This is the lottery help message, it will explain the basics of the lottery process :)",
			fields = {},
			footer = {
				text = string.format("Price for one ticket: %s goodies", tostring(cost))
			},
			color = Colours.embeds.notice
		}
		local function addField(title, desc)
			local temp = {
				name = title,
				value = desc,
				inline = true
			}
			table.insert(emb.fields, temp)
		end

		-- Add fields and send:
		for i, v in pairs(TextFile.lottery.helpEmbedFields) do addField(i, v) end
		Message:reply { embed = emb }
		return
	end

	-- Import Server file:
	local file_location = string.format("%s/%s.json", FileLocation.storage.serverdirectory, Message.guild.id)
	local server = jsonfile.import(file_location)
	if server == nil then
		Message:reply { embed = getErrorMessageEmbed("Internal", "Server file not found. Please annoy the bot upkeeper or the server owner about this!", usage)}
		return
	end
	if server['lottery'] == nil then server['lottery'] = {} end

	-- Add User or Add Count To User:
	local id = Message.author.id
	if server['lottery'][id] == nil then server['lottery'][id] = 0 end

	-- User Ticket Buying:
	local amount = math.abs(easy.number.forcetointeger(userinput, 1))
	local full_cost = amount * cost * -1
	local success, status = Goodies:modifyBalance(id, full_cost)

	-- Return if transaction was unsuccessful:
	if success == false then
		Message:reply { embed = getErrorMessageEmbed("Math", status, usage)}
		return
	end

	-- Write Server File:
	server['lottery'][id] = server['lottery'][id] + amount
	local usertickets = server['lottery'][id]
	local total = 0
	for _, v in pairs(server['lottery']) do
		total = total + v
	end
	jsonfile.export(file_location, server)

	Message:reply { embed = {
		title = string.format("Purchased %s lottery ticket(s)!", amount),
		description = string.format("You have currently %s active tickets.\nThere are currently %s tickets active (Your percentage: %s%%)", usertickets, total, usertickets/total*100),
		color = Colours.embeds.success
	}}
end

function Lottery:draw(Message, Caller, args, ...)
	local usage = "drawlottery (requires being server owner)"
	if Message.guild == nil then
		Message:reply { embed = getErrorMessageEmbed("Syntax", "This command only works on servers.", usage)}
		return
	end
	if Message.author.id ~= Message.guild.ownerId then
		Message:reply { embed = getErrorMessageEmbed("Permission", "This command can only be run as server owner.", usage)}
		return
	end

	-- Import Server File:
	local file_location = string.format("%s/%s.json", FileLocation.storage.serverdirectory, Message.guild.id)
	local server = jsonfile.import(file_location)
	if server == nil then
		Message:reply { embed = getErrorMessageEmbed("Internal", "Server file not found.", usage)}
		return
	end

	-- Check validity of lottery table:
	if server['lottery'] == nil then server['lottery'] = {} end
	local total = 0
	for _, v in pairs(server['lottery']) do
		total = total + v
	end	
	if server['lottery'] == {} or total == 0 then
		Message:reply { embed = getErrorMessageEmbed("Friends", "Not enough tickets have been purchased.", usage)}
		return
	end

	-- Get all variables:
	local jackpot = total * Config.goodies.lottery.ticket_cost
	local taxed = jackpot * Config.goodies.lottery.tax
	local reward = jackpot - taxed

	-- Pick a Winner Randomly:
	local winnerid = 0
	local pool = server['lottery']
	local random = math.random(1, total)

	local sum = 0
	for id, amount in pairs(pool) do
		sum = sum + amount
		if sum >= random then
			winnerid = id
			break
		end
	end

	-- Transfer rewards:
	if winnerid == nil or winnerid == 0 then
		Message:reply { embed = getErrorMessageEmbed("Internal", "A winner could not be chosen, please try again later.", usage)}
		return
	end
	local success, status = Goodies:modifyBalance(winnerid, reward, true)
	if success == false then
		Message:reply { embed = getErrorMessageEmbed("Transfer", status)}
	end
	Goodies:modifyBalance(bot.user.id, taxed, true)

	-- Send Confirmation Message:
	local pingAll = {}
	for id, _ in pairs(pool) do table.insert(pingAll, string.format("<@%s>", id)) end
	Message:reply(string.format("The lottery results are being drawn! %s", table.concat(pingAll, ", ")))
	Message:reply { embed = {
		title = "Lottery Draw Results",
		description = string.format("<@%s> has won the jackpot of %s goodies! (their winning chance was: %s%%)", winnerid, reward, server['lottery'][winnerid]/total*100),
		color = Colours.embeds.notice
	}}

	-- Remove used tickets:
	server['lottery'] = {}
	jsonfile.export(file_location, server)
end

function Lottery:status(Message, Caller, args, ...)
	local usage = "lotterystatus"
	if Message.guild == nil then
		Message:reply { embed = getErrorMessageEmbed("Syntax", "This command can only be run on a server.", usage)}
		return
	end

	local file_location = string.format("%s/%s.json", FileLocation.storage.serverdirectory, Message.guild.id)
	local server = jsonfile.import(file_location)
	if server == nil then
		Message:reply { embed = getErrorMessageEmbed("Internal", "Server file not found.", usage)}
		return
	end
	if server['lottery'] == nil then server['lottery'] = {} end

	-- Variables:
	local cost = Config.goodies.lottery.ticket_cost
	local ticket_count = 0
	local people_count = 0

	local most_tickets_per_person = 0
	for _, tickets in pairs(server['lottery']) do
		people_count = people_count + 1
		ticket_count = ticket_count + tickets
		if tickets > most_tickets_per_person then most_tickets_per_person = tickets end
	end

	-- Top Bidders:
	local top_ids = {}
	for id, tickets in pairs(server['lottery']) do
		if tickets == most_tickets_per_person then table.insert(top_ids, id) end
	end
	local top_bidders = {}
	for _, id in pairs(top_ids) do table.insert(top_bidders, string.format("<@%s>", id)) end
	local mention_top_bidders = table.concat(top_bidders, ", ")

	-- Format Top Bidders:
	if mention_top_bidders == "" then
		mention_top_bidders = "nobody... *yet*"
	else
		mention_top_bidders = mention_top_bidders .. string.format(" (%s tickets)", most_tickets_per_person)
	end

	-- Caller Stats:
	local temp = server['lottery'][Message.author.id]
	local temp_chance = 0
	if temp == nil then
		temp = 0
	end
	if ticket_count ~= 0 then
		temp_chance = temp/ticket_count*100
	end
	local caller_stats = {
		string.format("Your tickets: %s", temp),
		string.format("Winning chance: %s%%", temp_chance)
	}

	-- Assemble Embed:
	local emb = {
		title = "Lottery Status",
		description = string.format("Jackpot is currently at %s goodies.\nCurrently there are %s valid tickets. %s people are playing.", ticket_count*cost, ticket_count, people_count),
		fields = {},
		footer = { text = string.format("Current price of one ticket: %s goodies", cost) },
		color = Colours.embeds.default
	}
	local function addField(title, desc)
		table.insert(emb.fields, {name = title, value = desc, inline = true})
	end
	addField("Top Bidder(s)", mention_top_bidders)
	addField("Your Stats", table.concat(caller_stats, "\n"))

	Message:reply { embed = emb}
end

return Lottery
