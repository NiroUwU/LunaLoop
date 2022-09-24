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
	['went'] = {
		"ice skating", "hiking", "shopping", "skiing",
		['to'] = {
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
			['an'] = {
				"amusement park"
			},
			['the'] = {
				"zoo", "beach", "swimming pool",
				["local park"] = {
					"", "and yelled at children", "and fed some ducks", "and relaxed", "and watched birds"
				}
			}
		}
	},
	['made'] = {
		"a cake", "cookies", "pancakes", "a pizza",
		["friends with stray"] = {"cats", "dogs"}
	},
	['stayed at home and'] = {
		"played video games",
		['drew a picture of'] = {
			"beautiful scenaries", "themselves",
			['their'] = {"dream house", "favourite snacks", "favourite animals"}
		},
		['listened to'] = {"comfy music", "romantic music", "classical music", "rap music", "metal songs", "emo songs", "disney music"},
		["watched"] = {"a movie", "cat videos", "tutorials on how to install linux"}
	},
	['drank'] = {
		"some quality wine", "beer", "water from the city fountain", "coffee", "bubble-tea"
	},
	['ate'] = {
		"their favourite meals", "chocolate, then learned it had peanut butter, which one of them is allergic to, and went to the doctor",
		"their favourite snacks"
	},
	['joined'] = {
		"a cult", "a music band"
	},
	['threw'] = {
		"a party",
		['rocks at'] = {"cars", "children", "homeless people"}
	},
	['posted'] = {
		"memes in #general and got banned"
	},
	['created'] = {
		"a music band", "YouTube videos", "cringy TikTok videos"
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
	local temp = easy.table.readCompactStrings(Dating.activities)
	local activity_str = easy.table.randomIn(temp)

	local after = easy.table.randomIn(Dating.afterActivities)
	local comment = easy.table.randomIn(Dating.comments)

	local full = string.format("%s and %s %s.\nAfter that they %s.\n\nIn summary, they %s.", per1.mentionString, per2.mentionString, activity_str, after, comment)
	return tostring(full)
end

return Dating
