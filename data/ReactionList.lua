ReactionList = {}

local function add(id, reactionType, reaction, trigger)
	print("a")
	ReactionList[id] = MessageSubstring:init(id, reactionType, reaction, trigger)
end

-- Add Reactions here:
add("general_kenobi", "reply", 
	{"General Kenobi!"}, 
	{"hello there", "hello there!"}
)
add("hi_dad", "reply",
	{"Hi, I'm dad!"},
	{"i am", "i'm", "im"}
)

return ReactionList
