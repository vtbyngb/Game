 --[[
 	Basically Player Data, However...
 	You'll need to check DataStore for Data
 	If there is Data then Update the Table
 	Otherwise, the table will be the New Data. (For New Players)
  btw yes this is a module script
 --]]
local Constants = {
	--step
	Render = "render",
	
	--Attributes
	Movement_Attribute = "Movement",
	Attack_Attribute = "Attack",
	Last_Grounded_Attribute = "lastGrounded",
	Last_Time_Format = "last%s",
	
	Replicated_Movement = "ReplicatedMovement",
	Replicated_Attack = "ReplicatedAttack",
	
	--KeyCodes
	Block_Key = Enum.KeyCode.F,
	Critical_Key = Enum.KeyCode.R,
	
	-- Roll
	Roll_Speed = 80,
	Roll_Time = .25,
	Roll_Force_Factor = 1500,
	Roll_Cd = 1.5,
	Last_Roll = 0,
	
	--Jump
	Jump_Max_Power = 45, -- 65
	Jump_Power = 65, --65
	Jump_Coyote_Time = .15,
	Jump_Cd = 6, --1.25
	
	Last_Full_Power_Jump = 0,
	Jump_AttackCd = 1.25,
	
	--WallRun
	Wall_Check_Radius = 4,
	Wall_Run_Speed = 30,
	Wall_Distance = 3,
	Wall_Run_Db = 1,
	Last_Wall_Run = 0,
	
	--Sliding
	Slide_Speed = 30,
	Slide_Time = .15,
	
	-- Run
	Is_Running = false,
	Run_Speed = 30,
	Walk_Speed = 15,
}

return Constants
