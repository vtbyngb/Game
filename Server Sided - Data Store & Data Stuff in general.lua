--|| Services ||--
local RS = game:GetService("RunService")
local Players = game:GetService("Players")
local RepStore = game:GetService("ReplicatedStorage")
local DataStoreService = game:GetService("DataStoreService")

--|| Tables ||--
local Data_Table = {}
local Function_Table = {}
Function_Table.__index = Function_Table

--|| Variables ||--
local remotes = RepStore.Events

local ParryTime = 0.28
local Parry_DB = 1.35

local RollTime = 0.35
local Roll_DB = 1.5

--[[local CounterTime = 0.2
local Counter_DB = 2--]]

--|| Events ||--
local Effects_Event = remotes.ClientEffects

--|| Functions ||--
function Function_Table:Block(character)
	if self.CombatAttributes.Parry == true then warn('cheeze') return end
	
	if (tick() - self.CombatAttributes.Last_Parry) >= Parry_DB then --Parry If The Difference In Time Is >= DB
		self.CombatAttributes.Parry = true
		Effects_Event:FireAllClients("Parry_Warning", character)
		task.wait(ParryTime)
		self.CombatAttributes.Last_Parry = tick()
		self.CombatAttributes.Parry = false
	end
end

function Function_Table:Roll(character)
	if self.CombatAttributes.Roll == true then return end
	
	if (tick() - self.CombatAttributes.Last_Roll) >= Roll_DB then
		self.CombatAttributes.Roll = true
		Effects_Event:FireAllClients("Roll", character)
		task.wait(RollTime)
		self.CombatAttributes.Last_Roll = tick()
		self.CombatAttributes.Roll = false
	end
end

function Function_Table:Counter(CounterTime, Counter_DB, character)
	if self.CombatAttributes.Counter == true then return end
	
	if (tick() - self.CombatAttributes.Last_Counter) >= Counter_DB then
		self.CombatAttributes.Counter = true
		Effects_Event:FireAllClients("Counter", character)
		task.wait(CounterTime)
		self.CombatAttributes.Last_Counter = tick()
		self.CombatAttributes.Counter = false
	end
end

function Set_NetworkOwnerShip(NPC)
	for i,v in NPC:GetDescendants() do
		if v:IsA("BasePart") then
			local Connection
			
			Connection = RS.Heartbeat:Connect(function()
				if NPC.HumanoidRootPart.Anchored == true then return end
				v:SetNetworkOwner(nil)
			end)
			
			NPC.Humanoid.Died:Once(function()
				Connection:Disconnect()
			end)
			
			--print(v)
		end
	end
end

--|| Player Events ||--
Players.PlayerAdded:Connect(function(Player)
	Player.CharacterAdded:Once(function(Character)
		Data_Table[Player.UserId] = {
			CombatAttributes = { --Combat Attributes Such As Blocking ETC. Reset when join or died
				Parry = false,
				Last_Parry = 0,
				
				Roll = false,
				Last_Roll = 0,
				
				Counter = false,
				Last_Counter = 0,
				Counters_Are_On_CD = false, -- If multiple counters is busted I'll add this
				
				IFrame = false,
			},
			
			Nen = { --Everything Nen Related.
				Initiated = false, --Whether you have nen or not.

				NenType = { --What's your nen type, you can have multiple if you're lucky.

				},

				NenLevels = { --Hatsu Mastery.
					Enhancer = {
						Level = 0,
						MaxLevel = 0,
						Effectiveness = 0,
					},

					Transmutor = {
						Level = 0,
						MaxLevel = 0,
						Effectiveness = 0,
					},

					Emission = {
						Level = 0,
						MaxLevel = 0,
						Effectiveness = 0,
					},

					Manipulation = {
						Level = 0,
						MaxLevel = 0,
						Effectiveness = 0,
					},

					Conjuration = {
						Level = 0,
						MaxLevel = 0,
						Effectiveness = 0,
					},

					Specialization = {
						Level = 0,
						MaxLevel = 0,
						Effectiveness = 0,
					},
				},	

				NenAdvancements = { -- Nen Manipulation skills.
					Ten = {
						Unlocked = false,
						Points = 0,
					},

					Zetsu = {
						Unlocked = false,
						Points = 0,
					},

					Ren = {
						Unlocked = false,
						Points = 0,
					},

					Hatsu = {
						Unlocked = false,
						Points = 0,
					},

					--Advanced Applications
					Gyo = {
						Unlocked = false,
						Points = 0,
					},

					In = {
						Unlocked = false,
						Points = 0,
					},

					En = {
						Unlocked = false,
						Points = 0,
					},

					Shu = {
						Unlocked = false,
						Points = 0,
					},

					Ko = {
						Unlocked = false,
						Points = 0,
					},

					Ken = {
						Unlocked = false,
						Points = 0,
					},

					Ryu = {
						Unlocked = false,
						Points = 0,
					},
				},

				BindingVows = { --not possible to break
					WithOthers = {
						--UserId, BindingVow

					},

					WithSelf = {

					}
				},
			},
			
			CharacterStats = { -- Basic Character Things such as health, Posture, Age, and Nen potential.
				Health = 100,
				MaxStructure = 20,
				--AP = 0,
				--DP = 0,
				Years = 0,
				MaximumYears = 80,
				Agility = 0,
				MaxStamina = 20,
				MAP = 0, -- Maximum Aura Points.
				PAP = math.random(8000,25000), -- Potential Aura Points. The Amount Of Aura You Can Expend Before Passing Out.
				AAP = 0, -- Actual Aura Points, it's basically Aura output.
				MindPoints = 0, --Points you spend when creating an ability.
			},
			
			CharacterSkills = { --Abilities such as cooking, Navigation, Medical Abilities, etc.
				Cooking = {

				},

				MedicalAbilities = {

				},

				Navigation = {

				},

			},
			
			HunterStatus = { --Hunter stuff
				Rank = nil,
				HunterType = nil,
				HunterExamAttempts = 0,
				HasHunterCard = nil,
			},
		}
		local New_Table = Data_Table[Player.UserId]
		setmetatable(New_Table, Function_Table)
		--[[he Data is right above, however it's not being saved yet if I did save it I'd use
		DataStoreService:GetDataStore("Player_Data"):GetAsync(key) ; to check data then
		DataStoreService:GetDataStore("Player_Data"):SetAsync(key) ; to Save Data	--]]
	end)
end)


Players.PlayerRemoving:Connect(function(Player)
	-- The Data is right above, but since I'm in testing I'm not gonna save the data yet because of how the Datastore API functions
end)

--|| NPC Data ||--
task.spawn(function()
	for i,v in workspace:GetChildren() do
		local humanoid = v:FindFirstChild("Humanoid")

		if humanoid then
			--|| Stop Fling ||--
			humanoid:GetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
			humanoid:GetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
			
			
			Set_NetworkOwnerShip(v)

			--|| Main ||--
			local NPC = v
			Data_Table[NPC.Name] = {
				CombatAttributes = { --Combat Attributes Such As Blocking ETC. Reset when join or died
					Parry = false,
					Last_Parry = 0,

					Roll = false,
					Last_Roll = 0,

					Counter = false,
					Last_Counter = 0,
					Counters_Are_On_CD = false, -- If multiple counters is busted I'll add this

					IFrame = false,
				},

				Nen = { --Everything Nen Related.
					Initiated = false, --Whether you have nen or not.

					NenType = { --What's your nen type, you can have multiple if you're lucky.

					},

					NenLevels = { --Hatsu Mastery.
						Enhancer = {
							Level = 0,
							MaxLevel = 0,
							Effectiveness = 0,
						},

						Transmutor = {
							Level = 0,
							MaxLevel = 0,
							Effectiveness = 0,
						},

						Emission = {
							Level = 0,
							MaxLevel = 0,
							Effectiveness = 0,
						},

						Manipulation = {
							Level = 0,
							MaxLevel = 0,
							Effectiveness = 0,
						},

						Conjuration = {
							Level = 0,
							MaxLevel = 0,
							Effectiveness = 0,
						},

						Specialization = {
							Level = 0,
							MaxLevel = 0,
							Effectiveness = 0,
						},
					},	

					NenAdvancements = { -- Nen Manipulation skills.
						Ten = {
							Unlocked = false,
							Points = 0,
						},

						Zetsu = {
							Unlocked = false,
							Points = 0,
						},

						Ren = {
							Unlocked = false,
							Points = 0,
						},

						Hatsu = {
							Unlocked = false,
							Points = 0,
						},

						--Advanced Applications
						Gyo = {
							Unlocked = false,
							Points = 0,
						},

						In = {
							Unlocked = false,
							Points = 0,
						},

						En = {
							Unlocked = false,
							Points = 0,
						},

						Shu = {
							Unlocked = false,
							Points = 0,
						},

						Ko = {
							Unlocked = false,
							Points = 0,
						},

						Ken = {
							Unlocked = false,
							Points = 0,
						},

						Ryu = {
							Unlocked = false,
							Points = 0,
						},
					},

					BindingVows = { --not possible to break
						WithOthers = {
							--UserId, BindingVow

						},

						WithSelf = {

						}
					},
				},

				CharacterStats = { -- Basic Character Things such as health, Posture, Age, and Nen potential.
					Health = 100,
					MaxStructure = 20,
					--AP = 0,
					--DP = 0,
					Years = 0,
					MaximumYears = 80,
					Agility = 0,
					MaxStamina = 20,
					MAP = 0, -- Maximum Aura Points.
					PAP = math.random(8000,25000), -- Potential Aura Points. The Amount Of Aura You Can Expend Before Passing Out.
					AAP = 0, -- Actual Aura Points, it's basically Aura output.
					MindPoints = 0, --Points you spend when creating an ability.
				},

				CharacterSkills = { --Abilities such as cooking, Navigation, Medical Abilities, etc.
					Cooking = {

					},

					MedicalAbilities = {

					},

					Navigation = {

					},

				},

				HunterStatus = { --Hunter stuff
					Rank = nil,
					HunterType = nil,
					HunterExamAttempts = 0,
					HasHunterCard = nil,
				},
			}
			local New_Table = Data_Table[NPC.Name]
			setmetatable(New_Table, Function_Table)

			humanoid.died:Once(function()
				for Iteration, Value in v:GetDescendants() do
					Value:Destroy()
				end
				setmetatable(New_Table, nil)
				Data_Table[NPC.Name] = nil
			end)
		end
	end
end)

--|| Return Metatable||--
function Return_Meta(Iteration) --For i, V in pairs. i stands for Iteration basically meaning the number for loops in table, while Key would be for dictionaries in this context
	local Meta_Table = Data_Table[Iteration]
	return Meta_Table
end

return Return_Meta
