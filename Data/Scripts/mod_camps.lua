--- @class ModCamps Manage camps entities
--- @field campEntities table List of camp entities
--- @field locations table List of different spawning locations
--- @field difficulty table List of different difficulties
--- @field meshes table List of different meshes to spawn (string)
ModCamps = {
	campEntities = {},

	locations = {
		test = { x = 526, y = 3560, z = 27 },
	},

	difficulty = {
		easy = 2,
		medium = 3,
		hard = 4,
	},

	meshes = {
		fireplace = "Objects/buildings/refugee_camp/fireplace.cgf",
		tents = {
			"Objects/structures/tent_cuman/tent_cuman_small_v1.cgf",
			--"Objects/structures/tent_cuman/tent_cuman_v6.cgf",
			--"Objects/structures/tent/tent.cgf",
		},
		crates = {
			"Objects/props/crates/crate_long.cgf",
			"Objects/props/crates/crate_short.cgf",
		},
	}
}

--- Spawn a camp entity at the given location with the given difficulty
--- @param _campName string Name of the camp entity
--- @param _locationName string Name of the location
--- @param _difficulty string Difficulty of the camp (default: easy)
function ModCamps:SpawnCamp(_campName, _locationName, _difficulty)
	local spawnParams = {
		class = "CampEntity",
		name = _campName,
		position = self.locations[_locationName],
	}
	local camp = System.SpawnEntity(spawnParams)
	camp.name = _campName

	if (not (type(_difficulty) == "string")) then
		ModUtils:Log(_campName .. " spawned with default difficulty")
	end
	camp.difficulty = self.difficulty[_difficulty] or self.difficulty.easy

	self:SpawnMeshes(_campName, self.locations[_locationName])

	--TODO: make sure that it doesnt spawn an second time
	ModSoul:SpawnCommander({ x = 983.452, y = 1554.807, z = 25.205 }, { x = 0, y = 90, z = 0 })

	QuestSystem.ResetQuest("quest_morebanditcamps")
	QuestSystem.ActivateQuest("quest_morebanditcamps")
	if (not QuestSystem.IsQuestStarted("quest_morebanditcamps")) then
		QuestSystem.StartQuest("quest_morebanditcamps")
		QuestSystem.StartObjective("quest_morebanditcamps", "startBattle", false)
	end

	--TODO: This function is actually called every time there's a loading screen and i don't want to add a new camp to the list every time
	table.insert(self.campEntities, camp)
	ModUtils:Log("Size of campEntities list : " .. #self.campEntities)
end

--- Spawn all meshes for the camp entity
--- @param _campName string Name of the camp entity
--- @param _position table Position of the camp entity (x, y, z)
function ModCamps:SpawnMeshes(_campName, _position)

	local tentPosition, tentOrientation, cratePosition, crateOrientation = { x = 0, y = 0, z = 0 }

	if (_campName == "TestCamp") then
		tentPosition = { x = 525, y = 3563, z = 27 }
		tentOrientation = { x = 0, y = 360, z = 0 }

		cratePosition = { x = 523, y = 3559, z = 27 }
		crateOrientation = { x = 10, y = 10, z = 0 }
	end

	-- fireplace
	local fireplace = System.SpawnEntity({ class = "BasicEntity", name = "fireplace", position = _position })
	fireplace:LoadObject(0, self.meshes.fireplace)

	-- tents
	local tent = System.SpawnEntity({ class = "BasicEntity", name = "tent", position = tentPosition, orientation = tentOrientation })
	local randomTent = math.random(1, #self.meshes.tents)
	tent:LoadObject(0, self.meshes.tents[randomTent])

	-- crates
	local crate = System.SpawnEntity({ class = "BasicEntity", name = "crate", position = cratePosition, orientation = crateOrientation })
	local randomCrate = math.random(1, #self.meshes.crates)
	crate:LoadObject(0, self.meshes.crates[randomCrate])
end