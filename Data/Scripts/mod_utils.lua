--- @class ModUtils Utility functions
ModUtils = {}

--- Logs a message to the console
--- @param _message string Message to log
function ModUtils:Log(_message)
	System.LogAlways("$5[" .. ModMain.name .. "] " .. tostring(_message))
end

--- Logs a message to the screen
--- @param _message string Message to show
--- @param _forceClear boolean Force clear the screen (default: false)
--- @param _time number Time in seconds to show the message (default: 3)
function ModUtils:LogOnScreen(_message, _forceClear, _time)
	Game.SendInfoText(tostring(_message), _forceClear or false, nil, _time or 3)
end

--- Prints the player's location to the console and the screen
function ModUtils:PrintLoc()
	local pos = player:GetWorldPos()
	self:Log(string.format("{ x = %.3f, y = %.3f, z = %.3f }", pos.x, pos.y, pos.z))
	self:LogOnScreen(Vec2Str(pos), true, 10)
end
System.AddCCommand(ModMain.prefix .. 'Loc', 'ModUtils:PrintLoc()', "Prints the player's location")

--- Teleports the player to the given position
--- @param _xyz string Position to teleport to (x y z) or camp name (test)
function ModUtils:Teleport(_xyz)
	if (_xyz == "npc") then
		local pos = { x = ModQuest.npcPosition.x, y = ModQuest.npcPosition.y + 2, z = ModQuest.npcPosition.z }
		player:SetWorldPos(pos)
		return
	end

	if (_xyz == "camp") then
		local pos = ModCamps.locations["test"]
		player:SetWorldPos(pos)
		return
	end

	local function SplitStringToCoordinates(_string)
		local coordinates = { "x", "y", "z" }
		local result = {}
		local i = 1
		for value in string.gmatch(_string, "%d+") do
			result[coordinates[i]] = tonumber(value)
			i = i + 1
		end
		return result
	end
	local pos = SplitStringToCoordinates(_xyz)
	self:LogOnScreen("Teleported to " .. pos.x .. ", " .. pos.y .. ", " .. pos.z, true, 5)
	player:SetWorldPos(pos)
end
System.AddCCommand(ModMain.prefix .. 'Teleport', 'ModUtils:Teleport(%line)', "Teleports the player to the given position")

--- Shows the intro banner from startup (temporary)
function ModUtils:ShowTextbox()
	local message = "<font color='#ff8b00' size='28'>More Bandit Camps</font>" .. "\n"
			.. "<font color='#333333' size='20'>Antstar609</font>"

	Game.ShowTutorial(message, 3, false, true);
end
System.AddCCommand(ModMain.prefix .. 'ShowText', 'ModUtils:ShowText()', "Shows the intro banner from startup")