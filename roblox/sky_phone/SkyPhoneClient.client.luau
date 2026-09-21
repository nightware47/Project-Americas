--!strict
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local pGui = player:WaitForChild("PlayerGui")
local screenGui = script.Parent :: ScreenGui

local SkyPhone = require(screenGui:WaitForChild("Modules"):WaitForChild("SkyPhone"))
local c = SkyPhone.build(screenGui)
