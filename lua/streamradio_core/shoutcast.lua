local StreamRadioLib = StreamRadioLib

StreamRadioLib.Shoutcast = StreamRadioLib.Shoutcast or {}

local LIB = StreamRadioLib.Shoutcast
table.Empty(LIB)

local LIBUtil = StreamRadioLib.Util
local LIBUrl = StreamRadioLib.Url
local LIBHttp = StreamRadioLib.Http

local g_streamUrl = "https://yp.shoutcast.com/sbin/tunein-station.m3u"
local g_browseByGenreUrl = "https://directory.shoutcast.com/Home/BrowseByGenre"

local g_list_cache = LIBUtil.CreateCacheArray(2048)

local g_genres = {
	{
		title = "Alternative",
		subitems = {
			{
				title = "Adult Alternative"
			},
			{
				title = "Britpop"
			},
			{
				title = "Classic Alternative"
			},
			{
				title = "College"
			},
			{
				title = "Dancepunk"
			},
			{
				title = "Dream Pop"
			},
			{
				title = "Emo"
			},
			{
				title = "Goth"
			},
			{
				title = "Grunge"
			},
			{
				title = "Hardcore"
			},
			{
				title = "Indie Pop"
			},
			{
				title = "Indie Rock"
			},
			{
				title = "Industrial"
			},
			{
				title = "LoFi"
			},
			{
				title = "Modern Rock"
			},
			{
				title = "New Wave"
			},
			{
				title = "Noise Pop"
			},
			{
				title = "Post Punk"
			},
			{
				title = "Power Pop"
			},
			{
				title = "Punk"
			},
			{
				title = "Ska"
			},
			{
				title = "Xtreme"
			}
		}
	},
	{
		title = "Blues",
		subitems = {
			{
				title = "Acoustic Blues"
			},
			{
				title = "Chicago Blues"
			},
			{
				title = "Contemporary Blues"
			},
			{
				title = "Country Blues"
			},
			{
				title = "Delta Blues"
			},
			{
				title = "Electric Blues"
			},
			{
				title = "Cajun and Zydeco"
			}
		}
	},
	{
		title = "Classical",
		subitems = {
			{
				title = "Baroque"
			},
			{
				title = "Chamber"
			},
			{
				title = "Choral"
			},
			{
				title = "Classical Period"
			},
			{
				title = "Early Classical"
			},
			{
				title = "Impressionist"
			},
			{
				title = "Modern"
			},
			{
				title = "Opera"
			},
			{
				title = "Piano"
			},
			{
				title = "Romantic"
			},
			{
				title = "Symphony"
			}
		}
	},
	{
		title = "Country",
		subitems = {
			{
				title = "Alt Country"
			},
			{
				title = "Americana"
			},
			{
				title = "Bluegrass"
			},
			{
				title = "Classic Country"
			},
			{
				title = "Contemporary Bluegrass"
			},
			{
				title = "Contemporary Country"
			},
			{
				title = "Honky Tonk"
			},
			{
				title = "Hot Country Hits"
			},
			{
				title = "Western"
			}
		}
	},
	{
		title = "Easy Listening",
		subitems = {
			{
				title = "Exotica"
			},
			{
				title = "Light Rock"
			},
			{
				title = "Lounge"
			},
			{
				title = "Orchestral Pop"
			},
			{
				title = "Polka"
			},
			{
				title = "Space Age Pop"
			}
		}
	},
	{
		title = "Electronic",
		subitems = {
			{
				title = "Acid House"
			},
			{
				title = "Ambient"
			},
			{
				title = "Big Beat"
			},
			{
				title = "Breakbeat"
			},
			{
				title = "Dance"
			},
			{
				title = "Demo"
			},
			{
				title = "Disco"
			},
			{
				title = "Downtempo"
			},
			{
				title = "Drum and Bass"
			},
			{
				title = "Electro"
			},
			{
				title = "Garage"
			},
			{
				title = "Hard House"
			},
			{
				title = "House"
			},
			{
				title = "IDM"
			},
			{
				title = "Jungle"
			},
			{
				title = "Progressive"
			},
			{
				title = "Techno"
			},
			{
				title = "Trance"
			},
			{
				title = "Tribal"
			},
			{
				title = "Trip Hop"
			},
			{
				title = "Dubstep"
			}
		}
	},
	{
		title = "Folk",
		subitems = {
			{
				title = "Alternative Folk"
			},
			{
				title = "Contemporary Folk"
			},
			{
				title = "Folk Rock"
			},
			{
				title = "New Acoustic"
			},
			{
				title = "Traditional Folk"
			},
			{
				title = "World Folk"
			},
			{
				title = "Old Time"
			}
		}
	},
	{
		title = "Themes",
		subitems = {
			{
				title = "Adult"
			},
			{
				title = "Best Of"
			},
			{
				title = "Chill"
			},
			{
				title = "Eclectic"
			},
			{
				title = "Experimental"
			},
			{
				title = "Female"
			},
			{
				title = "Heartache"
			},
			{
				title = "Instrumental"
			},
			{
				title = "LGBT"
			},
			{
				title = "Love and Romance"
			},
			{
				title = "Party Mix"
			},
			{
				title = "Patriotic"
			},
			{
				title = "Rainy Day Mix"
			},
			{
				title = "Reality"
			},
			{
				title = "Sexy"
			},
			{
				title = "Shuffle"
			},
			{
				title = "Travel Mix"
			},
			{
				title = "Tribute"
			},
			{
				title = "Trippy"
			},
			{
				title = "Work Mix"
			}
		}
	},
	{
		title = "Rap",
		subitems = {
			{
				title = "Alternative Rap"
			},
			{
				title = "Dirty South"
			},
			{
				title = "East Coast Rap"
			},
			{
				title = "Freestyle"
			},
			{
				title = "Hip Hop"
			},
			{
				title = "Gangsta Rap"
			},
			{
				title = "Mixtapes"
			},
			{
				title = "Old School"
			},
			{
				title = "Turntablism"
			},
			{
				title = "Underground Hip Hop"
			},
			{
				title = "West Coast Rap"
			}
		}
	},
	{
		title = "Inspirational",
		subitems = {
			{
				title = "Christian"
			},
			{
				title = "Christian Metal"
			},
			{
				title = "Christian Rap"
			},
			{
				title = "Christian Rock"
			},
			{
				title = "Classic Christian"
			},
			{
				title = "Contemporary Gospel"
			},
			{
				title = "Gospel"
			},
			{
				title = "Praise and Worship"
			},
			{
				title = "Sermons and Services"
			},
			{
				title = "Southern Gospel"
			},
			{
				title = "Traditional Gospel"
			}
		}
	},
	{
		title = "International",
		subitems = {
			{
				title = "African"
			},
			{
				title = "Arabic"
			},
			{
				title = "Asian"
			},
			{
				title = "Bollywood"
			},
			{
				title = "Brazilian"
			},
			{
				title = "Caribbean"
			},
			{
				title = "Celtic"
			},
			{
				title = "Chinese"
			},
			{
				title = "European"
			},
			{
				title = "Filipino"
			},
			{
				title = "French"
			},
			{
				title = "Greek"
			},
			{
				title = "Hawaiian and Pacific"
			},
			{
				title = "Hindi"
			},
			{
				title = "Indian"
			},
			{
				title = "Japanese"
			},
			{
				title = "Hebrew"
			},
			{
				title = "Klezmer"
			},
			{
				title = "Korean"
			},
			{
				title = "Mediterranean"
			},
			{
				title = "Middle Eastern"
			},
			{
				title = "North American"
			},
			{
				title = "Russian"
			},
			{
				title = "Soca"
			},
			{
				title = "South American"
			},
			{
				title = "Tamil"
			},
			{
				title = "Worldbeat"
			},
			{
				title = "Zouk"
			},
			{
				title = "German"
			},
			{
				title = "Turkish"
			},
			{
				title = "Islamic"
			},
			{
				title = "Afrikaans"
			},
			{
				title = "Creole"
			}
		}
	},
	{
		title = "Jazz",
		subitems = {
			{
				title = "Acid Jazz"
			},
			{
				title = "Avant Garde"
			},
			{
				title = "Big Band"
			},
			{
				title = "Bop"
			},
			{
				title = "Classic Jazz"
			},
			{
				title = "Cool Jazz"
			},
			{
				title = "Fusion"
			},
			{
				title = "Hard Bop"
			},
			{
				title = "Latin Jazz"
			},
			{
				title = "Smooth Jazz"
			},
			{
				title = "Swing"
			},
			{
				title = "Vocal Jazz"
			},
			{
				title = "World Fusion"
			}
		}
	},
	{
		title = "Latin",
		subitems = {
			{
				title = "Bachata"
			},
			{
				title = "Banda"
			},
			{
				title = "Bossa Nova"
			},
			{
				title = "Cumbia"
			},
			{
				title = "Latin Dance"
			},
			{
				title = "Latin Pop"
			},
			{
				title = "Latin Rap and Hip Hop"
			},
			{
				title = "Latin Rock"
			},
			{
				title = "Mariachi"
			},
			{
				title = "Merengue"
			},
			{
				title = "Ranchera"
			},
			{
				title = "Reggaeton"
			},
			{
				title = "Regional Mexican"
			},
			{
				title = "Salsa"
			},
			{
				title = "Tango"
			},
			{
				title = "Tejano"
			},
			{
				title = "Tropicalia"
			},
			{
				title = "Flamenco"
			},
			{
				title = "Samba"
			}
		}
	},
	{
		title = "Metal",
		subitems = {
			{
				title = "Black Metal"
			},
			{
				title = "Classic Metal"
			},
			{
				title = "Extreme Metal"
			},
			{
				title = "Grindcore"
			},
			{
				title = "Hair Metal"
			},
			{
				title = "Heavy Metal"
			},
			{
				title = "Metalcore"
			},
			{
				title = "Power Metal"
			},
			{
				title = "Progressive Metal"
			},
			{
				title = "Rap Metal"
			},
			{
				title = "Death Metal"
			},
			{
				title = "Thrash Metal"
			}
		}
	},
	{
		title = "New Age",
		subitems = {
			{
				title = "Environmental"
			},
			{
				title = "Ethnic Fusion"
			},
			{
				title = "Healing"
			},
			{
				title = "Meditation"
			},
			{
				title = "Spiritual"
			}
		}
	},
	{
		title = "Decades",
		subitems = {
			{
				title = "30s"
			},
			{
				title = "40s"
			},
			{
				title = "50s"
			},
			{
				title = "60s"
			},
			{
				title = "70s"
			},
			{
				title = "80s"
			},
			{
				title = "90s"
			},
			{
				title = "00s"
			}
		}
	},
	{
		title = "Pop",
		subitems = {
			{
				title = "Adult Contemporary"
			},
			{
				title = "Barbershop"
			},
			{
				title = "Bubblegum Pop"
			},
			{
				title = "Dance Pop"
			},
			{
				title = "Idols"
			},
			{
				title = "Oldies"
			},
			{
				title = "JPOP"
			},
			{
				title = "Soft Rock"
			},
			{
				title = "Teen Pop"
			},
			{
				title = "Top 40"
			},
			{
				title = "World Pop"
			},
			{
				title = "KPOP"
			}
		}
	},
	{
		title = "R&B and Urban",
		subitems = {
			{
				title = "Classic R&B"
			},
			{
				title = "Contemporary R&B"
			},
			{
				title = "Doo Wop"
			},
			{
				title = "Funk"
			},
			{
				title = "Motown"
			},
			{
				title = "Neo Soul"
			},
			{
				title = "Quiet Storm"
			},
			{
				title = "Soul"
			},
			{
				title = "Urban Contemporary"
			}
		}
	},
	{
		title = "Reggae",
		subitems = {
			{
				title = "Contemporary Reggae"
			},
			{
				title = "Dancehall"
			},
			{
				title = "Dub"
			},
			{
				title = "Pop Reggae"
			},
			{
				title = "Ragga"
			},
			{
				title = "Rock Steady"
			},
			{
				title = "Reggae Roots"
			}
		}
	},
	{
		title = "Rock",
		subitems = {
			{
				title = "Adult Album Alternative"
			},
			{
				title = "British Invasion"
			},
			{
				title = "Classic Rock"
			},
			{
				title = "Garage Rock"
			},
			{
				title = "Glam"
			},
			{
				title = "Hard Rock"
			},
			{
				title = "Jam Bands"
			},
			{
				title = "Piano Rock"
			},
			{
				title = "Prog Rock"
			},
			{
				title = "Psychedelic"
			},
			{
				title = "Rock & Roll"
			},
			{
				title = "Rockabilly"
			},
			{
				title = "Singer and Songwriter"
			},
			{
				title = "Surf"
			},
			{
				title = "JROCK"
			},
			{
				title = "Celtic Rock"
			}
		}
	},
	{
		title = "Seasonal and Holiday",
		subitems = {
			{
				title = "Anniversary"
			},
			{
				title = "Birthday"
			},
			{
				title = "Christmas"
			},
			{
				title = "Halloween"
			},
			{
				title = "Hanukkah"
			},
			{
				title = "Honeymoon"
			},
			{
				title = "Kwanzaa"
			},
			{
				title = "Valentine"
			},
			{
				title = "Wedding"
			},
			{
				title = "Winter"
			}
		}
	},
	{
		title = "Soundtracks",
		subitems = {
			{
				title = "Anime"
			},
			{
				title = "Kids"
			},
			{
				title = "Original Score"
			},
			{
				title = "Showtunes"
			},
			{
				title = "Video Game Music"
			}
		}
	},
	{
		title = "Talk",
		subitems = {
			{
				title = "Comedy"
			},
			{
				title = "Community"
			},
			{
				title = "Educational"
			},
			{
				title = "Government"
			},
			{
				title = "News"
			},
			{
				title = "Old Time Radio"
			},
			{
				title = "Other Talk"
			},
			{
				title = "Political"
			},
			{
				title = "Scanner"
			},
			{
				title = "Spoken Word"
			},
			{
				title = "Sports"
			},
			{
				title = "Technology"
			},
			{
				title = "BlogTalk"
			}
		}
	},
	{
		title = "Misc",
		subitems = {}
	},
	{
		title = "Public Radio",
		subitems = {
			{
				title = "News"
			},
			{
				title = "Talk"
			},
			{
				title = "College"
			},
			{
				title = "Sports"
			},
			{
				title = "Weather"
			}
		}
	}
}

local function mapGenres(genres)
	local recursiveMapper = nil

	recursiveMapper = function(thisTab, thisKey, thisTitle)
		if not thisTab then
			return nil
		end

		local subItems = thisTab.subitems or {}

		local map = {}
		map.title = thisTitle
		map.key = thisKey

		for _, v in ipairs(subItems) do
			if not v then
				continue
			end

			local title = string.Trim(v.title or "")
			if title == "" then
				continue
			end

			local key = string.lower(title)
			if map.children and map.children[key] then
				continue
			end

			local subItem = recursiveMapper(v, key, title)
			if not subItem then
				continue
			end

			if not map.children then
				map.children = {}
			end

			if not map.childrenTitles then
				map.childrenTitles = {}
			end

			map.children[key] = subItem
			table.insert(map.childrenTitles, title)
		end

		return map
	end

	local map = recursiveMapper({subitems = genres})
	map.isRoot = true

	return map
end

local g_genres_map = mapGenres(g_genres)


function LIB.GetHierarchy(hierarchy)
	hierarchy = StreamRadioLib.GetHierarchy(hierarchy)
	local newHierarchy = {}

	for i, v in ipairs(hierarchy or {}) do
		v = tostring(v or "")
		v = string.Trim(v)
		v = string.lower(v)

		if v == "" then
			continue
		end

		table.insert(newHierarchy, v)
	end

	return newHierarchy
end

function LIB.GetHierarchyString(hierarchy)
	hierarchy = LIB.GetHierarchy(hierarchy)
	hierarchy = table.concat(hierarchy, "/")

	return hierarchy
end

function LIB.GetGenre(hierarchy)
	hierarchy = LIB.GetHierarchy(hierarchy)

	local curMap = g_genres_map

	for i, v in ipairs(hierarchy) do
		if not curMap then
			return nil
		end

		local children = curMap.children
		if not children then
			return nil
		end

		local child = children[v]
		if not child then
			return nil
		end

		curMap = child
	end

	if not curMap then
		return nil
	end

	return curMap
end

function LIB.GenreExists(hierarchy)
	local genres = LIB.GetGenre(hierarchy)
	if not genres then
		return false
	end

	return true
end

local g_format_blacklist = {
	-- ["audio/mpeg"] = true,
}

function LIB.IsValidFormat(format)
	format = tostring(format or "")
	format = string.Trim(format)
	format = string.lower(format)

	return not g_format_blacklist[format]
end

local lower = string.lower

local function sorter(a, b)
	local a_name = lower(a.name)
	local b_name = lower(b.name)

	return a_name < b_name
end

function LIB.GetListOfGenre(hierarchy, callback)
	hierarchy = LIB.GetHierarchy(hierarchy)
	local hierarchyString = LIB.GetHierarchyString(hierarchy)

	local genre = LIB.GetGenre(hierarchy)

	if not genre then
		callback(false)
		return
	end

	local cache = g_list_cache:Get(hierarchyString)
	if cache then
		callback(true, cache)
		return
	end

	g_list_cache:Remove(hierarchyString)

	local searchGenre = genre.title or ""
	if searchGenre == "" then
		callback(false)
		return
	end

	local resultCallback = function(success, data)
		if not success then
			callback(false)
			return
		end

		local body = string.Trim(data.body or "")
		if body == "" then
			callback(false)
			return
		end

		local listItems = StreamRadioLib.JSON.Decode(body)
		if not listItems then
			callback(false)
			return
		end

		local results = {}

		for i, v in ipairs(listItems) do
			local id = tostring(v.ID or "")
			local name = string.Trim(v.Name or "")
			local genre = string.Trim(v.Genre or "")
			local format = string.Trim(v.Format or "")

			if id == "" then
				continue
			end

			if name == "" then
				continue
			end

			if not LIB.IsValidFormat(format) then
				continue
			end

			local streamUrl = LIB.GetStreamUrlById(id)
			if not streamUrl then
				continue
			end

			local result = {}

			result.id = id
			result.name = name
			result.genre = genre
			result.format = format
			result.streamUrl = streamUrl

			table.insert(results, result)
		end

		table.sort(results, sorter)

		g_list_cache:Set(hierarchyString, results)
		callback(true, results)
	end

	LIBHttp.Request(g_browseByGenreUrl, resultCallback, {
		genrename = searchGenre
	}, "POST")
end

function LIB.GetStreamUrlById(id)
	id = tostring(id or "")

	if id == "" then
		return nil
	end

	local url = LIBUrl.URIAddParameter(g_streamUrl, {
		id = id,
	})

	return url
end

function LIB.IsShoutcastUrl(url)
	if string.StartsWith(url, g_streamUrl) then
		return true
	end

	local interface = StreamRadioLib.Interface.GetInterface("SHOUTcast")

	if interface and interface:CheckURL(url) then
		return true
	end

	return nil
end

return true

