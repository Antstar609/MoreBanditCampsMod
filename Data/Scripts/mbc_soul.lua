--- @class MBC_Soul Contains all the functions to spawn entities from the database (soul.xml)
--- @field tableName string Name of the database
--- @field rowOffset number Offset to match the line number in the xml file
--- @field soulType table List of all the types of entities (string)
--- @field wanderingGuards table List of all the wandering guards ids (string)
--- @field wanderingVillager table List of all the wandering villagers ids (string)
MBC_Soul = {
	tableName = "soul",
	rowOffset = 81,

	soulType = {
		"event_spawn_bandit", "villager", "bandit", "guard", "soldier", "cuman", "towns", "miner", "mason",
		"wanderer", "bailiff", "merchant", "weaponsmith", "circator", "lumberjack", "baker",
		"collier", "herold", "watchman", "innkeeper", "monk", "priest", "beggar",
		"executioner", "tanner", "armorer", "tailor", "blacksmith", "butcher", "shopGuard", "mercenary"
	},

	wanderingGuards = {
		"f1c2611b-f0b9-469e-aad5-cf713a11790f", "47310cda-0bcc-4541-9401-0a29e68a61a3",
		"79862e11-4c5a-4a76-8461-58ed2875de99", "9773c67c-b2c4-46ee-a505-f4c2094bd11d",
		"0651c27f-bfda-4cb5-8ccc-0e874b05fad2", "ab05a713-1fce-4576-b128-e06c5d32f03f",
		"8bc427f7-8802-4326-99fc-b337233ecf90", "614e4495-1746-4c0e-9c22-642da7a3a3c3",
		"8d2ca8d7-9442-498c-8778-77bbd47e0256", "147ba959-a969-48e1-9948-67893566865d",
		"8f58f1e4-cb02-46eb-a5e7-df6f8b2d7587", "b00fe10f-7e8f-48b5-8b55-ea64cfe8990d",
		"2622671b-6597-4c3e-9a19-e38a6f67107a", "e80212ac-3579-44a0-8009-9e76e5101e4f",
		"e5e59f4d-3e7c-4e4f-b5e4-f80e659497b9",
	},

	wanderingVillager = {
		"ef3e35a8-8147-4ca4-b220-c75848754e95",
	},
}

--- Check if the type is in the list of valid types (soulType)
--- @param _type string Type of the entity
--- @return boolean Is the type valid
function MBC_Soul:CheckValidType(_type)
	return table.contains(self.soulType, _type)
end

--- Get the gender of the entity by the archetype id
--- @param _id number Archetype id of the entity
--- @return string Returns either "NPC" for male and "NPC_Female" for female
function MBC_Soul:GetGender(_id)
	return (_id == 1) and "NPC_Female" or "NPC" -- ternary test
end

--- Get all souls from the database with the given type
--- @param _soulType string Type of the entity
--- @return table Souls data (nil if the type is not valid)
function MBC_Soul:GetSoulsFromDatabase(_soulType)
	if (not self:CheckValidType(_soulType)) then
		MBC_Utils:Log("Type not in the list")
		return nil
	end

	local souls = {}
	Database.LoadTable(self.tableName)
	local tableData = Database.GetTableInfo(self.tableName)
	local rows = tableData.LineCount - 1

	for i = 0, rows do
		local lineInfo = Database.GetTableLine(self.tableName, i)
		if (string.find(lineInfo.soul_name, _soulType, 1, true)) then
			local soulData = {
				name = lineInfo.soul_name,
				id = lineInfo.soul_id,
				archetype_id = lineInfo.soul_archetype_id,
				row = i + self.rowOffset,
			}

			-- to prevent bugged entity (not perfect for all entities)
			local activity = lineInfo.activity_0
			if (not (activity == "dummyWait")) then
				table.insert(souls, soulData)
			end
		end
	end

	return souls
end

--- Spawn n entities with the given type at the given position with an offset or at the player position
--- @param _entityType string Type of the entity
--- @param _position table Position of the entity (x, y, z)
--- @param _numberOfEntities number Number of entities to spawn
--- @param _offsetPosition number Offset of the position (default: 0)
--- @return table Entities spawned data (nil if no entity found)
function MBC_Soul:SpawnEntityByType(_entityType, _position, _numberOfEntities, _offsetPosition)
	local soul = self:GetSoulsFromDatabase(_entityType)
	if (soul == nil) then
		MBC_Utils:Log("No souls found")
		return
	end

	local entities = {}
	for _ = 1, (_numberOfEntities or 1) do
		local randomNumber = math.random(1, #soul)

		if (_offsetPosition ~= nil) then
			local offsetX = math.random(-_offsetPosition, _offsetPosition)
			local offsetY = math.random(-_offsetPosition, _offsetPosition)
			_position = { x = _position.x + offsetX, y = _position.y + offsetY, z = _position.z }
		end

		local spawnParams = {
			class = self:GetGender(soul[randomNumber].archetype_id),
			name = "mbc_" .. soul[randomNumber].name .. "_" .. soul[randomNumber].row,
			position = _position or player:GetWorldPos(),
			orientation = player:GetWorldPos(),
			properties = {
				sharedSoulGuid = soul[randomNumber].id,
				bSaved_by_game = 0,
			},
		}

		local entity = System.SpawnEntity(spawnParams)
		entity.AI.invulnerable = true
		entity.lootable = true
		entity.lootIsLegal = true

		table.insert(entities, entity)
	end

	return entities
end
System.AddCCommand(MBC_Main.prefix .. 'spawnEntityByType', 'MBC_Soul:SpawnEntityByType(%line)', "")

--- Spawn an entity with the given line number at the given position or at the player position
--- @param _lineNumber number Line number of the entity in the xml file
--- @param _position table Position of the entity (x, y, z)
function MBC_Soul:SpawnEntityByLine(_lineNumber, _position)
	local soul = Database.GetTableLine(self.tableName, _lineNumber - self.rowOffset)
	if (soul == nil) then
		MBC_Utils:Log("No souls found")
		return
	end

	local spawnParams = {
		class = self:GetGender(soul.soul_archetype_id),
		name = soul.soul_name .. "_" .. _lineNumber,
		position = _position or player:GetWorldPos(),
		orientation = player:GetWorldPos(),
		properties = {
			sharedSoulGuid = soul.soul_id,
		},
	}

	local entity = System.SpawnEntity(spawnParams)
	entity.AI.invulnerable = true
	entity.lootable = true
	entity.lootIsLegal = true
end
System.AddCCommand(MBC_Main.prefix .. 'spawnEntityByLine', 'MBC_Soul:SpawnEntityByLine(%line)', "")

--- Spawn a wandering villager at the player position
function MBC_Soul:SpawnWanderingGuard()
	local randomNumber = math.random(1, #self.wanderingGuards)
	local spawnParams = {
		class = "NPC",
		name = "wandering_guard" .. "_" .. randomNumber,
		position = player:GetWorldPos(),
		orientation = player:GetWorldPos(),
		properties = {
			sharedSoulGuid = self.wanderingGuards[randomNumber],
		},
	}

	local entity = System.SpawnEntity(spawnParams)
	entity.AI.invulnerable = true
end
System.AddCCommand(MBC_Main.prefix .. 'spawnWanderingGuard', 'MBC_Soul:SpawnWanderingGuard()', "Spawn a wandering guard")

--- Spawn the commander
--- @param _position table Position of the entity (x, y, z)
--- @param _orientation table Orientation of the entity (x, y, z)
function MBC_Soul:SpawnQuestNPC(_position, _orientation)
	local spawnParams = {
		class = "NPC",
		name = "QuestNPC",
		position = _position,
		orientation = _orientation,
		properties = {
			sharedSoulGuid = "48e0f0d5-27f4-ab1c-8ed4-887830e828a7",
			bSaved_by_game = 1,
			Saved_by_game = 1
		},
	}
	local entity = System.SpawnEntity(spawnParams)
	self:SetQuestNPCAttributes(entity)
end

--- Set the attributes of the quest npc
--- @param _entity table Entity to set the attributes
function MBC_Soul:SetQuestNPCAttributes(_entity)
	_entity:SetViewDistUnlimited()
	-- invincible
	_entity.soul:AddBuff("a218af80-b2a5-11ed-afa1-0242ac120002")

	_entity.GetActions = function(user, firstFast)
		local output = {}
		AddInteractorAction(output, firstFast, Action():hint("@ui_hud_talk"):action("use"):func(MBC_Quest.NCPInteract):interaction(inr_talk))
		return output
	end
end

--- Spawn an invisible npc to use it as a tag point for the camp entity
--- @param _position table Position of the tag point (x, y, z)
function MBC_Soul:SpawnTagPoint(_position)
	local spawnParams = {
		class = "NPC",
		name = "Tagpoint",
		position = _position,
		properties = {
			sharedSoulGuid = "1b036f85-f939-4ec6-89a3-0229a87fafaf",
			bSaved_by_game = 1,
			Saved_by_game = 1
		},
	}
	local entity = System.SpawnEntity(spawnParams)
	entity:Activate(0)
	-- invincible
	entity.soul:AddBuff("a218af80-b2a5-11ed-afa1-0242ac120002")

	-- to remove the ability to pick it
	entity.GetActions = function(user, firstFast)
		local output = {}
		return output
	end
	
	MBC_Camps.spawnedCamp.tagpoint = entity
end