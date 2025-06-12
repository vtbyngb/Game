--[[
	Controller - This module script implements the character controller class. This class
	handles character movement, momentum, and performing actions, as well as utility functions
	to read the humanoid's state.
--]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Constants = require(ReplicatedStorage.Constants)
local loadModules = require(ReplicatedStorage.Utility.loadModules)
local loadAnimations = require(ReplicatedStorage.Utility.loadAnimation)
local disconnectAndClear = require(ReplicatedStorage.Utility.disconnectAndClear)

local Actions = loadModules

local remotes = ReplicatedStorage.Events
local setActionRemote = remotes.SetAction

local Controller = {}
Controller.__index = Controller

function Controller.new(character: Model)
	-- Characters are not replicated atomically so we need to wait for children to replicate
	local humanoid = character:WaitForChild("Humanoid")
	local root = character:WaitForChild("HumanoidRootPart")
	local loadanims = loadAnimations.LoadAnimations(humanoid:WaitForChild("Animator"))

	local self = {
		character = character,
		humanoid = humanoid,
		root = root,
		inputDirection = Vector3.zero,
		moveDirection = Vector3.zero,
		connections = {},
		actionChanged = character:GetAttributeChangedSignal(Constants.Movement_Attribute),
	}

	setmetatable(self, Controller)
	return self
end

function Controller:setInputDirection(inputDirection: Vector3)
	--warn(inputDirection)
	if inputDirection.Magnitude > 1 then
		inputDirection = inputDirection.Unit
	end
	self.inputDirection = inputDirection
end

function Controller:isSwimming(): boolean
	local humanoidState = self.humanoid:GetState()
	return humanoidState == Enum.HumanoidStateType.Swimming
end

function Controller:isClimbing(): boolean
	local humanoidState = self.humanoid:GetState()
	return humanoidState == Enum.HumanoidStateType.Climbing
end

function Controller:isGrounded(): boolean
	--warn(self.humanoid.FloorMaterial ~= Enum.Material.Air)
	return self.humanoid.FloorMaterial ~= Enum.Material.Air
end

function Controller:IsStunned() : boolean
	return self.character:GetAttribute("Stunned") or false
end

function Controller:IsBlocking() : boolean
	local bool = false
	if self:getAction(Constants.Attack_Attribute) == "Block" then bool = true end
	return bool
end

function Controller:getAction(...): string
	return self.character:GetAttribute(...) or "None"
	--[[or self.character:GetAttribute("Stunned") --]]
end

function Controller:setAction(action: string, ...)
	local lastTimeAttribute = string.format(Constants.Last_Time_Format, action)

	self.character:SetAttribute(lastTimeAttribute, os.clock())
	self.character:SetAttribute(..., action)

	setActionRemote:FireServer(action, ...)
end

function Controller:getTimeSinceAction(action: string): number
	local lastTimeAttribute = string.format(Constants.Last_Time_Format, action)
	local lastTime = self.character:GetAttribute(lastTimeAttribute) or 0
	return os.clock() - lastTime
end

function Controller:getTimeSinceGrounded(): number
	local lastGroundedTime = self.character:GetAttribute(Constants.Last_Grounded_Attribute) or 0
	return os.clock() - lastGroundedTime
end

function Controller:performAction(action: string, ...)
	local actionModule = Actions[action]
	if not actionModule then
		warn(`Invalid action: {action}`)
		return
	end

	actionModule.perform(self, ...)
end

function Controller:getAcceleration(): number
	-- Check if the current action has a set acceleration to use
	local action = self:getAction(Constants.Movement_Attribute)
	local actionModule = Actions[action]
	if actionModule and actionModule.movementAcceleration then
		return actionModule.movementAcceleration
	end

	if self:isClimbing() then
		return Constants.LADDER_ACCELERATION
	elseif self:isSwimming() then
		return Constants.WATER_ACCELERATION
	elseif not self:isGrounded() then
		return Constants.AIR_ACCELERATION
	end

	return Constants.GROUND_ACCELERATION
end

function Controller:update(deltaTime: number)
	local isGrounded = self:isGrounded()

	-- Allow dashing and double jumping again once the character is grounded/climbing/swimming.
	-- Additionally, check if the current action needs to be cleared
	if isGrounded or self:isClimbing() or self:isSwimming() then
		self:tryClearGroundedAction()
	end

	if isGrounded then
		self.character:SetAttribute(Constants.Last_Grounded_Attribute, os.clock())
	end
	
	-- Move the character
	--self.humanoid:Move(self.moveDirection)
end

function Controller:tryClearGroundedAction()
	local action = self:getAction(Constants.Movement_Attribute)
	local actionModule = Actions[action]

	--warn(action)

	if actionModule and actionModule.clearOnGrounded then
		--warn(action)
		--warn(actionModule.clearOnGrounded)
		local minTimeInAction = actionModule.minTimeInAction or 0
		local timeSinceAction = self:getTimeSinceAction(action)
		if timeSinceAction >= minTimeInAction then
			self:setAction("None", Constants.Movement_Attribute)
		end
	end
end

function Controller:destroy()
	disconnectAndClear(self.connections)
end

return Controller
