--[[
	Replication - This script handles the replication of platforming actions that players are doing.
	Actions are validated and then replicated using an attribute on the character model.
--]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Constants = require(ReplicatedStorage.Constants)
local validateString = require(ServerScriptService.Utility.TypeValidation.validateString)
local validateAction = require(script.validateAction)

local ReturnMeta = require(script.Parent.CharacterSheet)

local remotes = ReplicatedStorage.Events
local setActionRemote = remotes.SetAction

local function onSetActionEvent(player: Player, action: string, Type: string )
	-- Validate arguments
	if not validateString(action) then
		player:Kick("Bruh Hacking?")
		return
	end

	-- Make sure the player has a character
	local character = player.Character
	if not character then
		return
	end

	-- Make sure this is a valid action
	if not validateAction(action) then
		return
	end
	
	-- Since the client is already setting ACTION_ATTRIBUTE, we have the server set a separate REPLICATED_ACTION_ATTRIBUTE.
	-- This avoids issues where a client with poor connection could have the attribute overwritten by the server.
	if Type == Constants.Movement_Attribute then
		character:SetAttribute(Constants.Replicated_Movement, action)
	elseif Type == Constants.Attack_Attribute then
		character:SetAttribute(Constants.Replicated_Attack, action)
	end
	
	if action == "Block" then
		local Meta_Table = ReturnMeta(player.UserId)
		Meta_Table:Block(character)
	end
	if action == "Roll" then
		local Meta_Table = ReturnMeta(player.UserId)
		Meta_Table:Roll(character)
	end
end

setActionRemote.OnServerEvent:Connect(onSetActionEvent)


--|| Modules For Replication Purposes ||-- Just Require them So That The Server Can Access It... PS this script contains Effects and it requires the server to replicate it for it to be visible on all clients
local Dash_Module = require(ReplicatedStorage.Actions.Combat.Actions.Dash)
