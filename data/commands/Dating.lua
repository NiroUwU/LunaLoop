Dating = {}
Dating.titles = {
	['success'] = {
		"LET'S GOOOOOOOOOOOOO", "It is dating time!", "Har har, love is in the air", "Awoooga!", "Something's getting spicy!", "Lovely",
		"Damn, it's getting hot in here...", "You cuties!", "Cute as fuck!", "Cute!", "Amazing!", "Kinda hot ;)"
	},
	['failed'] = {
		"Damn, that feels bad", "Damn, I feel you", "sad sad...", "Let me give you a hug", ":pensive:"
	}
}

Dating.activities = {
	['went to'] = {
		['a'] = {
			"bar", "fancy restaurant",
			['mall and got themselves'] = {
				['some'] = {"ice cream", "plushies", "bubble-tea"},
				"matching T-shirts"
			},
			['library and read'] = {
				['the'] = {"bible", "dictionary"},
				"their favourite books"
			}
		},
		['the'] = {
			["local park"] = {
				"", "and yelled at children", "and fed some ducks", "and relaxed", "and watched birds"
			}, "zoo", "beach", "swimming pool"
		}
	},
	['made'] = {
		"a cake",
		["friends with stray"] = {"cats", "dogs"}
	},
	['stayed at home and'] = {
		"played video games",
		['drew a picture of'] = {
			['their'] = {"dream house", "favourite snacks"},
			"beautiful scenaries",
			"their favourite animals"
		},
		['listened to'] = {"comfy music", "romantic music", "classical music", "rap music", "metal songs", "emo songs", "disney music"},
		["watched"] = {"a movie", "cat videos", "tutorials on how to install linux"}
	},
	['drank'] = {
		"quality wine", "beer", "water from the city fountain"
	},
	['ate'] = {
		"their favourite meals",
		"ate chocolate, then learned it had peanut butter, which one of them is allergic to, and went to the doctor"
	},
	['joined'] = {
		"a cult"
	}
}

Dating.afterActivities = {
	"held hands", "hugged eachother", "kissed each other", "fell asleep on a couch", "cuddled", "watched the stars", "awkwardly said bye and left"
}

Dating.comments = {
	"had a great time", "enjoyed themselves", "loved every second of it", "will never forget this special day", "had a blasting time", "had a lovely time",
	"would love to spend eternity like this", "couldn't have had a better time"
}


function Dating:getTitle(status)
	local out = easy.table.randomIn(Dating.titles[status])
	if out == nil then
		out = "Dating Results"
	end
	return tostring(out)
end

--@param per1 and...
--@param per2 ...have to be User Objects
function Dating:getDescription(per1, per2)
	local function concatAllActivities(tab, prev)
		local tmp = {}
		for i,v in pairs(tab) do
			if type(v) == "table" then
				local tmp2 = concatAllActivities(v, prev .. " " .. i)
				for _,k in pairs(tmp2) do
					table.insert(tmp, k)
				end
			elseif type(v) == "string" then
				local str = string.format("%s %s", prev, v)
				table.insert(tmp, str)
			end
		end
		return tmp
	end

	-- Add all 
	local temp = concatAllActivities(Dating.activities, "")
	--print(table.concat(temp, ", "))

	local activity_str = easy.table.randomIn(temp)

	local after = easy.table.randomIn(Dating.afterActivities)
	local comment = easy.table.randomIn(Dating.comments)

	local full = string.format("%s and %s %s.\nAfter that they %s.\n\nIn summary, they %s.", per1.mentionString, per2.mentionString, activity_str, after, comment)
	return tostring(full)
end

return Dating
