
ESX = nil
local Keys = {
	["ESC"] = 322, ["F1"] = 288, ["F2"] = 289, ["F3"] = 170, ["F5"] = 166, ["F6"] = 167, ["F7"] = 168, ["F8"] = 169, ["F9"] = 56, ["F10"] = 57,
	["~"] = 243, ["1"] = 157, ["2"] = 158, ["3"] = 160, ["4"] = 164, ["5"] = 165, ["6"] = 159, ["7"] = 161, ["8"] = 162, ["9"] = 163, ["-"] = 84, ["="] = 83, ["BACKSPACE"] = 177,
	["TAB"] = 37, ["Q"] = 44, ["W"] = 32, ["E"] = 38, ["R"] = 45, ["T"] = 245, ["Y"] = 246, ["U"] = 303, ["P"] = 199, ["["] = 39, ["]"] = 40, ["ENTER"] = 18,
	["CAPS"] = 137, ["A"] = 34, ["S"] = 8, ["D"] = 9, ["F"] = 23, ["G"] = 47, ["H"] = 74, ["K"] = 311, ["L"] = 182,
	["LEFTSHIFT"] = 21, ["Z"] = 20, ["X"] = 73, ["C"] = 26, ["V"] = 0, ["B"] = 29, ["N"] = 249, ["M"] = 244, [","] = 82, ["."] = 81,
	["LEFTCTRL"] = 36, ["LEFTALT"] = 19, ["SPACE"] = 22, ["RIGHTCTRL"] = 70,
	["HOME"] = 213, ["PAGEUP"] = 10, ["PAGEDOWN"] = 11, ["DELETE"] = 178,
	["LEFT"] = 174, ["RIGHT"] = 175, ["TOP"] = 27, ["DOWN"] = 173,
	["NENTER"] = 201, ["N4"] = 108, ["N5"] = 60, ["N6"] = 107, ["N+"] = 96, ["N-"] = 97, ["N7"] = 117, ["N8"] = 61, ["N9"] = 118
}

OrganizationBlip = {}
local PlayerData, CurrentAction = {}
local currentjoblocation = nil
local morfQTE       			= 0
local morf_poochQTE 			= 0
local myJob 					= nil
local HasAlreadyEnteredMarker   = false
local LastZone                  = nil
local CurrentAction             = nil
local CurrentActionMsg          = ''
local CurrentActionData         = {}

CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getWiadrosSharedPaczkaObject', function(obj) ESX = obj end)
		Citizen.Wait(5)
  	end
  
  	while ESX.GetPlayerData().job == nil do
		Citizen.Wait(50)
	end

	PlayerData = ESX.GetPlayerData()
	refreshBlip()
end)

AddEventHandler('esx_morf:hasEnteredMarker', function(zone)

	if Config.Organisations[PlayerData.hiddenjob.name] and PlayerData.hiddenjob.grade >= Config.Organisations[PlayerData.hiddenjob.name].DrugsSettings.from then

		ESX.UI.Menu.CloseAll()
	
		if zone == 'MorfField' then
		CurrentAction     = zone
		CurrentActionMsg2  = _U('press_collect_morf')
		CurrentActionData = {}
		elseif zone == 'MorfProcessing' then
			if morfQTE >= 5 then
			CurrentAction     = zone
			CurrentActionMsg2  = _U('press_process_morf')
			CurrentActionData = {}
			end
		elseif zone == 'MorfDealer' then
			if morf_poochQTE >= 1 then
			CurrentAction     = zone
			CurrentActionMsg2  = _U('press_sell_morf')
			CurrentActionData = {}
			end
		end
	end
end)

AddEventHandler('esx_morf:hasExitedMarker', function(zone)
	CurrentAction = nil
	ESX.UI.Menu.CloseAll()

	if zone == 'MorfField' then
		TriggerServerEvent('esx_morf:stopHarvestMorf')
	elseif zone == 'MorfProcessing' then
	TriggerServerEvent('esx_morf:stopTransformMorf')
	elseif zone == 'MorfDealer' then
		TriggerServerEvent('esx_morf:stopSellMorf')
	end
end)

-- efekt morfiny
RegisterNetEvent('esx_morf:onPot')
AddEventHandler('esx_morf:onPot', function()
	RequestAnimSet("MOVE_M@DRUNK@SLIGHTLYDRUNK")
	while not HasAnimSetLoaded("MOVE_M@DRUNK@SLIGHTLYDRUNK") do
		Citizen.Wait(5)
	end
	TaskStartScenarioInPlace(PlayerPedId(), "WORLD_HUMAN_SMOKING_POT", 0, true)
	Citizen.Wait(5000)
	DoScreenFadeOut(1000)
	Citizen.Wait(1000)
	ClearPedTasksImmediately(PlayerPedId())
	SetTimecycleModifier("spectator5")
	SetPedMotionBlur(PlayerPedId(), true)
	SetPedArmour(PlayerPedId(), 15)
	SetPedMovementClipset(PlayerPedId(), "MOVE_M@DRUNK@SLIGHTLYDRUNK", true)
	SetPedIsDrunk(PlayerPedId(), true)
	DoScreenFadeIn(1000)
	Citizen.Wait(500000)
	DoScreenFadeOut(1000)
	Citizen.Wait(5000)
	DoScreenFadeIn(1000)
	ClearTimecycleModifier()
	ResetScenarioTypesEnabled()
	ResetPedMovementClipset(PlayerPedId(), 0)
	SetPedIsDrunk(PlayerPedId(), false)
	SetPedMotionBlur(PlayerPedId(), false)
	SetPedArmour(PlayerPedId(), 40)
end)

-- marker
Citizen.CreateThread(function()
		while true do

			Citizen.Wait(5)

			local coords = GetEntityCoords(PlayerPedId())

			for k,v in pairs(Config.Zones) do
				if GetDistanceBetweenCoords(coords, v.x, v.y, v.z, true) < Config.DrawDistance then
					DrawMarker(Config.MarkerType, v.x, v.y, v.z, 0.0, 0.0, 0.0, 0, 0.0, 0.0, Config.ZoneSize.x, Config.ZoneSize.y, Config.ZoneSize.z, Config.MarkerColor.r, Config.MarkerColor.g, Config.MarkerColor.b, 100, false, true, 2, false, false, false, false)
				end
			end

		end	
end)


if Config.ShowBlips then
	-- oznaczenie
	Citizen.CreateThread(function()
		for k,v in pairs(Config.Zones) do
			local blip = AddBlipForCoord(v.x, v.y, v.z)

			SetBlipSprite (blip, v.sprite)
			SetBlipDisplay(blip, 4)
			SetBlipScale  (blip, 0.9)
			SetBlipColour (blip, v.color)
			SetBlipAsShortRange(blip, true)

			BeginTextCommandSetBlipName("STRING")
			AddTextComponentString(v.name)
			EndTextCommandSetBlipName(blip)
		end
	end)
end


-- itemsy
RegisterNetEvent('esx_morf:ReturnInventory')
AddEventHandler('esx_morf:ReturnInventory', function(morfNbr, morfpNbr, jobName, currentZone)
	morfQTE			= morfNbr
	morf_poochQTE	= morfpNbr
	myJob			= jobName
	TriggerEvent('esx_morf:hasEnteredMarker', currentZone)
end)

-- menu w markerze
Citizen.CreateThread(function()
		while true do

			Citizen.Wait(5)

			local coords      = GetEntityCoords(PlayerPedId())
			local isInMarker  = false
			local currentZone = nil

			for k,v in pairs(Config.Zones) do
				if(GetDistanceBetweenCoords(coords, v.x, v.y, v.z, true) < Config.ZoneSize.x / 2) then
					isInMarker  = true
					currentZone = k
				end
			end

			if isInMarker and not hasAlreadyEnteredMarker then
				hasAlreadyEnteredMarker = true
				lastZone				= currentZone
				TriggerServerEvent('esx_morf:GetUserInventory', currentZone)
			end

			if not isInMarker and hasAlreadyEnteredMarker then
				hasAlreadyEnteredMarker = false
			TriggerEvent('esx_morf:hasExitedMarker', lastZone)
			end
		end
end)

-- klawisze
Citizen.CreateThread(function()
	while true do
		Citizen.Wait(10)
		if CurrentAction ~= nil then
			ESX.ShowHelpNotification(CurrentActionMsg2)

			if IsControlJustReleased(0, Keys['E']) and IsPedOnFoot(PlayerPedId()) then
				if CurrentAction == 'MorfField' then
					TriggerServerEvent('esx_morf:startHarvestMorf')
				elseif CurrentAction == 'MorfProcessing' then
					TriggerServerEvent('esx_morf:startTransformMorf')
				elseif CurrentAction == 'MorfDealer' then
					TriggerServerEvent('esx_morf:startSellMorf')
				end
				
				CurrentAction = nil
			end
		else
			Citizen.Wait(500)
		end
	end
end)