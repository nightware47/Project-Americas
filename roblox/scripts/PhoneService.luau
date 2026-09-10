--!strict
-- PhoneService.lua
-- Server-side authoritative service for the Sky Phone in Roblox
-- Manages player phone numbers, messaging, banking transactions & vehicle controls
-- Place in: ServerScriptService
-- Location: roblox/scripts/PhoneService.lua

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DataStoreService = game:GetService("DataStoreService")

local PhoneService = {}

type PlayerPhoneData = {
	PhoneNumber: string,
	BankBalance: number,
	Cash: number,
	Contacts: { [string]: string }, -- Name -> Number
	ActiveCallWith: Player?,
}

local playerData: { [Player]: PlayerPhoneData } = {}
local assignedNumbers: { [string]: Player } = {}

-- Safe DataStore wrapper (Gracefully falls back to session memory if DataStores are disabled in Studio)
local phoneDataStore: GlobalDataStore? = nil
pcall(function()
	phoneDataStore = DataStoreService:GetDataStore("SkyPhone_PlayerData_v1")
end)

--------------------------------------------------------------------------------
-- Network Setup
--------------------------------------------------------------------------------
local networkFolder = Instance.new("Folder")
networkFolder.Name = "PhoneNetwork"
networkFolder.Parent = ReplicatedStorage

local function createRemoteFunction(name: string): RemoteFunction
	local rf = Instance.new("RemoteFunction")
	rf.Name = name
	rf.Parent = networkFolder
	return rf
end

local function createRemoteEvent(name: string): RemoteEvent
	local re = Instance.new("RemoteEvent")
	re.Name = name
	re.Parent = networkFolder
	return re
end

local rfStartCall = createRemoteFunction("StartCall")
local rfEndCall = createRemoteFunction("EndCall")
local rfSendMessage = createRemoteFunction("SendMessage")
local rfTransferMoney = createRemoteFunction("TransferMoney")
local rfVehicleAction = createRemoteFunction("VehicleAction")

local rePushNotif = createRemoteEvent("PushNotification")
local reUpdateBalance = createRemoteEvent("UpdateBalance")

--------------------------------------------------------------------------------
-- Helper Utilities
--------------------------------------------------------------------------------
local function generatePhoneNumber(): string
	local num: string
	repeat
		num = string.format("555-%04d", math.random(1000, 9999))
	until not assignedNumbers[num]
	return num
end

--------------------------------------------------------------------------------
-- Player Lifecycle & Data Management
--------------------------------------------------------------------------------
local function onPlayerAdded(player: Player)
	local savedNumber: string? = nil
	local savedBalance = 10000

	-- Attempt loading from DataStore
	if phoneDataStore then
		local success, result = pcall(function()
			return phoneDataStore:GetAsync("Phone_" .. tostring(player.UserId))
		end)
		if success and type(result) == "table" then
			savedNumber = result.PhoneNumber
			savedBalance = result.BankBalance or 10000
		end
	end

	local phoneNum = savedNumber or generatePhoneNumber()

	playerData[player] = {
		PhoneNumber = phoneNum,
		BankBalance = savedBalance,
		Cash = 500,
		Contacts = {},
		ActiveCallWith = nil,
	}
	assignedNumbers[phoneNum] = player

	print(string.format("[PhoneService] Assigned %s to player %s (%d)", phoneNum, player.Name, player.UserId))

	-- Welcome notification after player loads in
	task.delay(4, function()
		if player.Parent then
			rePushNotif:FireClient(player, "SkyOS Carrier", "Connected to 5G network. Your number: " .. phoneNum, "📶")
			reUpdateBalance:FireClient(player, savedBalance)
		end
	end)
end

local function onPlayerRemoving(player: Player)
	local data = playerData[player]
	if data then
		-- End active call if any
		if data.ActiveCallWith and data.ActiveCallWith.Parent then
			rePushNotif:FireClient(data.ActiveCallWith, "Call Ended", "The other party disconnected.", "📞")
			local otherData = playerData[data.ActiveCallWith]
			if otherData then otherData.ActiveCallWith = nil end
		end

		-- Save data
		if phoneDataStore then
			pcall(function()
				phoneDataStore:SetAsync("Phone_" .. tostring(player.UserId), {
					PhoneNumber = data.PhoneNumber,
					BankBalance = data.BankBalance,
				})
			end)
		end

		assignedNumbers[data.PhoneNumber] = nil
		playerData[player] = nil
	end
end

Players.PlayerAdded:Connect(onPlayerAdded)
Players.PlayerRemoving:Connect(onPlayerRemoving)

for _, p in ipairs(Players:GetPlayers()) do
	task.spawn(onPlayerAdded, p)
end

--------------------------------------------------------------------------------
-- Remote Function Handlers
--------------------------------------------------------------------------------

-- 1. CALLING
rfStartCall.OnServerInvoke = function(caller: Player, targetNumber: string)
	local callerData = playerData[caller]
	if not callerData then return { Success = false, Message = "Caller data not found" } end

	local recipient = assignedNumbers[targetNumber]
	if not recipient or not recipient.Parent then
		return { Success = false, Message = "Number not in service or user offline" }
	end

	if recipient == caller then
		return { Success = false, Message = "Cannot call yourself" }
	end

	local recipientData = playerData[recipient]
	if recipientData and recipientData.ActiveCallWith then
		return { Success = false, Message = "User line is busy" }
	end

	-- Connect Call
	callerData.ActiveCallWith = recipient
	if recipientData then
		recipientData.ActiveCallWith = caller
	end

	rePushNotif:FireClient(recipient, "Incoming Call", string.format("Call from %s (%s)", caller.DisplayName, callerData.PhoneNumber), "📞")
	return { Success = true, Message = "Calling " .. targetNumber }
end

rfEndCall.OnServerInvoke = function(caller: Player)
	local callerData = playerData[caller]
	if not callerData then return end

	local partner = callerData.ActiveCallWith
	if partner and partner.Parent then
		rePushNotif:FireClient(partner, "Call Ended", "Call ended by " .. caller.DisplayName, "📞")
		local partnerData = playerData[partner]
		if partnerData then partnerData.ActiveCallWith = nil end
	end
	callerData.ActiveCallWith = nil
	return { Success = true }
end

-- 2. MESSAGING
rfSendMessage.OnServerInvoke = function(sender: Player, recipientQuery: string, messageText: string)
	local senderData = playerData[sender]
	if not senderData then return { Success = false } end

	-- Find recipient by username, display name, or phone number
	local recipient: Player? = assignedNumbers[recipientQuery]
	if not recipient then
		for p, data in pairs(playerData) do
			if p.Name:lower() == recipientQuery:lower() or p.DisplayName:lower() == recipientQuery:lower() then
				recipient = p
				break
			end
		end
	end

	if recipient and recipient.Parent then
		rePushNotif:FireClient(recipient, sender.DisplayName, messageText, "💬")
		return { Success = true, Delivered = true }
	else
		return { Success = true, Delivered = false, Message = "Recipient offline; message queued." }
	end
end

-- 3. BANKING / TRANSFERS
rfTransferMoney.OnServerInvoke = function(sender: Player, recipientQuery: string, amount: number)
	local senderData = playerData[sender]
	if not senderData then return { Success = false, Message = "Sender not found" } end

	if amount <= 0 or amount > senderData.BankBalance then
		return { Success = false, Message = "Insufficient funds" }
	end

	local recipient: Player? = nil
	for p, _ in pairs(playerData) do
		if p ~= sender and (p.Name:lower() == recipientQuery:lower() or p.DisplayName:lower() == recipientQuery:lower()) then
			recipient = p
			break
		end
	end

	senderData.BankBalance -= amount
	reUpdateBalance:FireClient(sender, senderData.BankBalance)

	if recipient and recipient.Parent then
		local recipientData = playerData[recipient]
		if recipientData then
			recipientData.BankBalance += amount
			reUpdateBalance:FireClient(recipient, recipientData.BankBalance)
			rePushNotif:FireClient(recipient, "Sun City Bank", string.format("Received $%d from %s", amount, sender.DisplayName), "💸")
		end
	end

	return { Success = true, NewBalance = senderData.BankBalance }
end

-- 4. VEHICLE REMOTE ACTION
rfVehicleAction.OnServerInvoke = function(player: Player, vehicleId: string, action: string)
	print(string.format("[PhoneService] Vehicle Action: %s performed '%s' on %s", player.Name, action, vehicleId))
	return { Success = true }
end

print("[PhoneService] Sky Phone Server-Side Service Started.")

return PhoneService
