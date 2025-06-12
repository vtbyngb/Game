--[[
	ControlScript - This script handles input and character control, redirecting default inputs
	to the Controller class.

	Since interfacing with the PlayerScripts is difficult without forking, a RenderStep loop
	is used to read movement and jump values from the local character's humanoid for input.
	Those values are then modified by the Controller and written back in order to implement
	features such as momentum.
--]]

--|| Services ||--
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")

--|| Modules ||--
local Constants = require(ReplicatedStorage.Constants)
local Controller = require(script.Parent.Controller)
local Animations = require(ReplicatedStorage.Utility.loadAnimation)
local EquipModule = require(ReplicatedStorage.Utility.EquipModule)
local loadModules = require(ReplicatedStorage.Utility.loadModules)

local MoreInputFunctions = require(script.MoreInputFunctions)

--|| Variables ||--
local player = Players.LocalPlayer
local camera = workspace.CurrentCamera
local last_Orient = nil

local currentController = nil
local wasJumping = false

local runAnimation


local function onCharacterAdded(character: Model)
	-- Create a new controller for the character
	local controller = Controller.new(character)
	
	--Set Up Combat
	character:SetAttribute(Constants.Attack_Attribute, "None")

	-- Clean up the controller when the character is Destroyed
	local ancestryChangedConnection
	ancestryChangedConnection = character.AncestryChanged:Connect(function()
		if not character:IsDescendantOf(game) then
			ancestryChangedConnection:Disconnect()
			controller:destroy()
			if currentController == controller then
				currentController = nil
			end
		end
	end)
	character.Humanoid:GetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
	character.Humanoid:GetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
	
	character.Humanoid.StateChanged:Connect(function(OldState, NewState)
		--warn(OldState, "  ,  ", NewState)
	end)
	
	currentController = controller
	runAnimation = Animations.getAnimationTrack("Run")
	MoreInputFunctions.new(character, currentController, runAnimation)
	UIS.InputBegan:Connect(MoreInputFunctions.Inputs)
end

local function onRenderStep(deltaTime: number)
	if not currentController then
		--warn(currentController, ", cheeze")
		return
	end

	-- Since the default control scripts are brittle and hard to hook into, we'll read input from the humanoid itself.
	-- GetMoveVelocity() returns inputDirection * walkSpeed so we need to divide by walkSpeed again to normalize it.
	local moveDirection = currentController.humanoid:GetMoveVelocity() / currentController.humanoid.WalkSpeed
	local isJumping = currentController.humanoid.Jump
	local shouldJump = isJumping and not wasJumping

	-- Reset humanoid Jump to false to disable the default jumping mechanics
	currentController.humanoid.Jump = false
	wasJumping = isJumping

	-- Update our own controller with the move direction
	currentController:setInputDirection(moveDirection)
	currentController:update(deltaTime)
	
	MoreInputFunctions.LockMouseToCenter()
	MoreInputFunctions.Run_Check()
	
	if currentController:IsStunned() then
		if currentController.humanoid.AutoRotate == false then
			return
		end
		currentController.humanoid.AutoRotate = false
	else
		if currentController.humanoid.AutoRotate ~= true then
			currentController.humanoid.AutoRotate = true
		end
	end
	
	MoreInputFunctions.Block(currentController)
	-- If the humanoid was attempting to jump, perform a jump action
	if shouldJump then
		currentController:performAction("BaseJump")
	end
end

local function initialize()
	player.CharacterAdded:Connect(onCharacterAdded)

	-- The default controls are bound on renderstep, so we'll bind at the highest priority to override them
	RunService:BindToRenderStep(Constants.Render , Enum.RenderPriority.Last.Value , onRenderStep)
	
	if player.Character then
		onCharacterAdded(player.Character)
	end
end

initialize()
