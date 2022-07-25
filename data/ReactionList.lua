ReactionList = {}

local function add(reactionType, reaction, trigger)
	table.insert(ReactionList, MessageSubstring.new(reactionType, reaction, trigger))
end

-- Add Reactions here:
add("reply", "General Kenobi!", {"hello there", "hello there!"})

return ReactionList
