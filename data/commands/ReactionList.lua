ReactionList = {}

local function add(id, reactionType, reaction, trigger)
	print("a")
	ReactionList[id] = MessageSubstring:init(id, reactionType, reaction, trigger)
end

return ReactionList
