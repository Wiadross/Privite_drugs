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
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(5)
  	end
  
  	while ESX.GetPlayerData().job == nil do
		Citizen.Wait(50)
	end

	PlayerData = ESX.GetPlayerData()
	refreshBlip()
end)

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
	PlayerData = xPlayer
end)

RegisterNetEvent('esx:setHiddenJob')
AddEventHandler('esx:setHiddenJob', function(hiddenjob)
	PlayerData.hiddenjob = hiddenjob
	deleteBlip()
	refreshBlip()
end)

CreateThread(function()
	while true do 
		Citizen.Wait(50000)
		deleteBlip()
		Citizen.Wait(500)
		refreshBlip()
	end
end)

function refreshBlip()
	if PlayerData.hiddenjob ~= nil and Config.Blips[PlayerData.hiddenjob.name] then
		local blip = AddBlipForCoord(Config.Blips[PlayerData.hiddenjob.name])
		SetBlipSprite (blip, 765)
		SetBlipDisplay(blip, 4)
		SetBlipScale  (blip, 0.8)
		SetBlipColour (blip, 2)
		SetBlipAsShortRange(blip, true)
		BeginTextCommandSetBlipName("STRING")
		AddTextComponentString("# Drugi prywatne - " ..PlayerData.hiddenjob.label)
		EndTextCommandSetBlipName(blip)
		table.insert(OrganizationBlip, blip)
	end
end

function deleteBlip()
	if OrganizationBlip[1] ~= nil then
		for i=1, #OrganizationBlip, 1 do
			RemoveBlip(OrganizationBlip[i])
			table.remove(OrganizationBlip, i)
		end
	end
end

function OpenOrganisationActionsMenu()
    ESX.UI.Menu.CloseAll()
	local elements = {}
	if PlayerData.hiddenjob.grade >= Config.Interactions[PlayerData.hiddenjob.name].handcuffs then
		table.insert(elements, { label = 'Kajdanki', value = 'handcuffs' })
	end
	if PlayerData.hiddenjob.grade >= Config.Interactions[PlayerData.hiddenjob.name].repair then
		table.insert(elements, { label = 'Napraw pojazd', value = 'repair' })
	end
	if PlayerData.hiddenjob.grade >= Config.Interactions[PlayerData.hiddenjob.name].worek then
		table.insert(elements, { label = 'Worek', value = 'worek' })
	end

    ESX.UI.Menu.Open(
    'default', GetCurrentResourceName(), 'organisation_actions',
    {
        title    = ' '..Config.Organisations[PlayerData.hiddenjob.name].Label,
        align    = 'center',
        elements = elements
	}, function(data, menu)
		if data.current.value == 'handcuffs' then
			menu.close()
			exports['esx_kajdanki']:HandcuffsAction()
		elseif data.current.value == 'repair' then
			menu.close()
			exports['esx_mecanojob']:whyuniggarepairingme()
		elseif data.current.value == 'worek' then
			TriggerServerEvent('esx_stocks:CheckHeadBag')
		end
    end, function(data, menu)
        menu.close()
    end)
end

function OpenInventoryMenu(station)
	if Config.Organisations[PlayerData.hiddenjob.name] and PlayerData.hiddenjob.grade >= Config.Organisations[PlayerData.hiddenjob.name].Inventory.from then
		ESX.UI.Menu.CloseAll()
		local elements = {
			{label = "Włóż", value = 'deposit'},
			{label = "Wyciągnij", value = 'withdraw'}
		}
		ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'inventory',
		{
			title    = ' '..Config.Organisations[PlayerData.hiddenjob.name].Label,
			align    = 'center',
			elements = elements
		}, function(data, menu)
			if data.current.value == 'withdraw' then

				ESX.TriggerServerCallback('esx_stocks:getSharedInventoryInJob', function(inventory)
	
					local elements = {}
					for i=1, #inventory.items, 1 do
						local item = inventory.items[i]
						if item.count > 0 then
						table.insert(elements, {
							label = item.label .. ' x' .. item.count,
							type = 'item_standard',
							value = item.name
						})
						end
					end
					ESX.UI.Menu.Open(
						'default', GetCurrentResourceName(), 'stocks_menu',
						{
						title    = ' '..Config.Organisations[PlayerData.hiddenjob.name].Label,
						align    = 'center',
						elements = elements
						},
						function(data, menu)
						local itemName = data.current.value
						ESX.UI.Menu.Open(
							'dialog', GetCurrentResourceName(), 'stocks_menu_get_item_count',
							{
							title = "Ilość",
							},
							function(data2, menu2)
								local count = tonumber(data2.value)
								if count == nil then
									ESX.ShowNotification("~r~Nieprawidłowa wartość!")
								else
									menu2.close()
									menu.close()
									TriggerServerEvent('esx_stocks:getItemInStock', data.current.type, data.current.value, count, station)
									
									ESX.SetTimeout(500, function()
										OpenInventoryMenu('society_'..PlayerData.hiddenjob.name, Config.Organisations[PlayerData.hiddenjob.name].Inventory.from)
									end)
								end
							end,
							function(data2, menu2)
								menu2.close()
							end
						)
						end,
						function(data, menu)
							menu.close()
						end
					)
				end, station)
			else
				ESX.TriggerServerCallback('esx_stocks:getPlayerInventory', function(inventory)
					local elements = {}
					for i=1, #inventory.items, 1 do
						local item = inventory.items[i]
						if item.count > 0 then
						table.insert(elements, {label = item.label .. ' x' .. item.count, type = 'item_standard', value = item.name})
						end
					end
					ESX.UI.Menu.Open(
						'default', GetCurrentResourceName(), 'stocks_menu',
						{
						title    = "Ekwipunek",
						align    = 'center',
						elements = elements
						},
						function(data, menu)
						local itemName = data.current.value
						local itemType = data.current.type
						ESX.UI.Menu.Open(
							'dialog', GetCurrentResourceName(), 'stocks_menu_put_item_count',
							{
							title = "Ilość"
							},
							function(data2, menu2)
								local count = tonumber(data2.value)
								if count == nil then
									ESX.ShowNotification("~r~Nieprawidłowa wartość!")
								else
									menu2.close()
									menu.close()
									TriggerServerEvent('esx_stocks:putItemInStock', itemType, itemName, count, station)
									ESX.SetTimeout(500, function()
										OpenInventoryMenu('society_'..PlayerData.hiddenjob.name, Config.Organisations[PlayerData.hiddenjob.name].Inventory.from)

									end)
								end
							end,
							function(data2, menu2)
							menu2.close()
							end
						)
						end,
						function(data, menu)
						menu.close()
						end
					)
				end)
			end
		end, function(data, menu)
			menu.close()
			if isUsing then
				isUsing = false
				TriggerServerEvent('Privite_drugs:setStockUsed', 'society_'..PlayerData.hiddenjob.name, 'inventory', false)
				zoneName = 'inventory'
				OpenInventoryMenu('society_' .. PlayerData.hiddenjob.name)
			end
		end)
	else
		ESX.ShowNotification('~o~Nie jesteś osobą, która może korzystać z szafki.')
	end
end

AddEventHandler('Privite_drugs:hasEnteredMarker', function(zone)
	if zone == 'Cloakroom' then
		CurrentAction     = 'menu_cloakroom'
		CurrentActionMsg  = ('~y~Naciśnij ~INPUT_CONTEXT~ aby otworzyć przebieralnie.')
		CurrentActionData = {}
	elseif zone == 'Inventory' then
		CurrentAction     = 'menu_armory'
		CurrentActionMsg  = ('~y~Naciśnij ~INPUT_CONTEXT~ aby otworzyć szafkę.')
		CurrentActionData = {station = station}
	elseif zone == 'Weapons' then
		CurrentAction     = 'menu_armory_weapons'
		CurrentActionMsg  = ('~y~Naciśnij ~INPUT_CONTEXT~ aby otworzyć zbrojownie.')
		CurrentActionData = {station = station}
	elseif zone == "BossMenu" then
		CurrentAction     = 'menu_boss_actions'
		CurrentActionMsg  = "~y~Naciśnij ~INPUT_PICKUP~ aby otworzyć panel zarządzania"
		CurrentActionData = {}
	elseif zone == "Contract" then
		CurrentAction     = 'menu_contract_actions'
		CurrentActionMsg  = "~ys~Naciśnij ~INPUT_PICKUP~ aby zakupić kontrakt na broń"
		CurrentActionData = {}
	end
end)

AddEventHandler('Privite_drugs:hasExitedMarker', function(zone)
	if not isInShopMenu then
		ESX.UI.Menu.CloseAll()
	end

	zoneName = nil
	CurrentAction = nil
end)

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(1)
		if PlayerData.hiddenjob ~= nil then
			if Config.Organisations[PlayerData.hiddenjob.name] then
				local playerPed = PlayerPedId()
				local isInMarker  = false
				local currentZone = nil
				local coords, letSleep = GetEntityCoords(playerPed), true
				
				for k,v in pairs(Config.Organisations[PlayerData.hiddenjob.name]) do
					if GetDistanceBetweenCoords(coords, v.coords, true) < Config.DrawDistance then
						letSleep = false
						--DrawMarker(27, v.coords, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 2.0, 2.0, 2.0, 30, 225, 200, 90, false, true, 2, true, false, false, false)
						DrawMarker(27, v.coords, 0.0, 0.0, 0.0, 0, 0.0, 0.0, 2.5, 2.5, 2.5, 73, 48, 255, 175, false, true, 2, true, false, false, false)
					end

					if(GetDistanceBetweenCoords(coords, v.coords, true) < 1.5) then
						isInMarker  = true
						currentZone = k
					end
				end

				if (isInMarker and not HasAlreadyEnteredMarker) or (isInMarker and LastZone ~= currentZone) then
					HasAlreadyEnteredMarker = true
					LastZone                = currentZone
					TriggerEvent('Privite_drugs:hasEnteredMarker', currentZone)
				end

				if not isInMarker and HasAlreadyEnteredMarker then
					HasAlreadyEnteredMarker = false
					TriggerEvent('Privite_drugs:hasExitedMarker', LastZone)
				end

				if letSleep then
					Citizen.Wait(5000)
				end
			else
				Citizen.Wait(5000)
			end
		else
			Citizen.Wait(5000)
		end
	end
end)

CreateThread(function()
	while true do
		Citizen.Wait(1)
		if CurrentAction then
			ESX.ShowHelpNotification(CurrentActionMsg)
			if IsControlJustReleased(0, 38) and PlayerData.hiddenjob and Config.Organisations[PlayerData.hiddenjob.name] and not exports['esx_policejob']:isHandcuffed() and not exports['esx_ambulancejob']:getDeathStatus() then
			--if IsControlJustReleased(0, 38) and PlayerData.hiddenjob and Config.Organisations[PlayerData.hiddenjob.name] and not exports['esx_policejob']:isHandcuffed() and not exports['esx_ambulancejob']:getDeathStatus() then
				if CurrentAction == 'menu_armory' then
					local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()
					if closestDistance > 3 or closestPlayer == -1 then
						ESX.TriggerServerCallback('Privite_drugs:checkStock', function()
							if not isUsed then
								isUsing = true
								TriggerServerEvent('Privite_drugs:setStockUsed', 'society_'..PlayerData.hiddenjob.name, 'inventory', true)
								zoneName = 'inventory'
									OpenInventoryMenu('society_' .. PlayerData.hiddenjob.name)
							else
								ESX.ShowNotification("~r~Ktoś właśnie używa tej szafki")
							end
						end, 'society_'..PlayerData.hiddenjob.name, 'inventory')
					else
						ESX.ShowNotification('Stoisz za blisko innego gracza!')
					end
				elseif CurrentAction == 'menu_armory_weapons' then
						local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()
						if closestDistance > 3 or closestPlayer == -1 then
							OpenWeaponsMenu(CurrentActionData.station)
						else
							ESX.ShowNotification('Stoisz za blisko innego gracza!')
						end
				elseif CurrentAction == 'menu_cloakroom' then
					--OpenOrganisationPrywatne()
					--OpenCloakroomMenu(zone)
					ESX.TriggerServerCallback('esx_stocks:getPlayerDressing', function(dressing)
						local elements = {}
			
						for i=1, #dressing, 1 do
							table.insert(elements, {
								label = dressing[i],
								value = i
							})
						end
						ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'player_dressing', {
							title = ' '..Config.Organisations[PlayerData.hiddenjob.name].Label,
							align    = 'center',
							elements = elements
						}, function(data2, menu2)
							TriggerEvent('skinchanger:getSkin', function(skin)
								ESX.TriggerServerCallback('esx_stocks:getPlayerOutfit', function(clothes)
									TriggerEvent('skinchanger:loadClothes', skin, clothes)
									TriggerEvent('esx_skin:setLastSkin', skin)
			
									TriggerEvent('skinchanger:getSkin', function(skin)
										TriggerServerEvent('esx_skin:save', skin)
									end)
								end, data2.current.value)
							end)
						end, function(data2, menu2)
							menu2.close()
						end)
					end)
				elseif CurrentAction == 'menu_boss_actions' then
					ESX.UI.Menu.CloseAll()
					OpenBossMenu(PlayerData.hiddenjob.name, Config.Organisations[PlayerData.hiddenjob.name].BossMenu.from)
				elseif CurrentAction == 'menu_contract_actions' then
					--if Config.Organisations[PlayerData.hiddenjob.name].Contract.from then
						OpenContractMenu()
					--end
				end
				CurrentAction = nil
			end
		else
			Citizen.Wait(500)
		end
		if not IsPedInAnyVehicle(PlayerPedId()) then
			if IsControlJustReleased(0, 168) and GetEntityHealth(PlayerPedId()) > 100 and PlayerData.hiddenjob and Config.Interactions[PlayerData.hiddenjob.name] then
				OpenOrganisationActionsMenu(PlayerData.hiddenjob.name)
			end
		end
	end		
end)

OpenContractMenu = function()
	ESX.UI.Menu.CloseAll()
	local elements = {
		{label =  Config.Organisations[PlayerData.hiddenjob.name].Contract.Utils.Label..' $'..Config.Organisations[PlayerData.hiddenjob.name].Contract.Utils.Price, value = Config.Organisations[PlayerData.hiddenjob.name].Contract.Utils.Price},
		{label = 'Amunicja $'..Config.Organisations[PlayerData.hiddenjob.name].Contract.Utils.Ammo.Price, value = 'ammo'}
	}
	ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'esx_jest_git', { title = ' '..Config.Organisations[PlayerData.hiddenjob.name].Label, align = 'center', elements = elements}, function(data, menu) if data.current.value == Config.Organisations[PlayerData.hiddenjob.name].Contract.Utils.Price then klameczka = Config.Organisations[PlayerData.hiddenjob.name].Contract.Utils.Weapon TriggerServerEvent('Privite_drugs', klameczka) elseif data.current.value == 'ammo' then TriggerServerEvent('esx_stocks:Magazynek') end
	end, function(data, menu)
		menu.close()
	end)
end

function OpenOrganisationPrywatne()
    ESX.UI.Menu.CloseAll()
	local elements = {
		{label = 'Ubrania Prywatne', value = 'player_dressing'},
		--{label = 'Zapisz Ubranie', value = 'save_playerdressing'}
	}

    ESX.UI.Menu.Open(
    'default', GetCurrentResourceName(), 'organisation_actions',
    {
        title    = ' '..Config.Organisations[PlayerData.hiddenjob.name].Label,
        align    = 'center',
        elements = elements
	}, function(data, menu)
	if data.current.value == 'player_dressing' then

		ESX.TriggerServerCallback('esx_stocks:getPlayerDressing', function(dressing)
			local elements = {}

			for i=1, #dressing, 1 do
				table.insert(elements, {
					label = dressing[i],
					value = i
				})
			end
			ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'player_dressing', {
				title = ' '..Config.Organisations[PlayerData.hiddenjob.name].Label,
				align    = 'center',
				elements = elements
			}, function(data2, menu2)
				TriggerEvent('skinchanger:getSkin', function(skin)
					ESX.TriggerServerCallback('esx_stocks:getPlayerOutfit', function(clothes)
						TriggerEvent('skinchanger:loadClothes', skin, clothes)
						TriggerEvent('esx_skin:setLastSkin', skin)

						TriggerEvent('skinchanger:getSkin', function(skin)
							TriggerServerEvent('esx_skin:save', skin)
						end)
					end, data2.current.value)
				end)
			end, function(data2, menu2)
				menu2.close()
			end)
		end)
	elseif data.current.value == 'save_playerdressing' then
		ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'nazwa_ubioru', {
			title = ('Nazwa ubioru')
		}, function(data2, menu2)
			ESX.UI.Menu.CloseAll()

			TriggerEvent('skinchanger:getSkin', function(skin)
				TriggerServerEvent('Privite_drugs:saveOutfit', data2.value, skin, station)
				ESX.ShowNotification('Pomyślnie zapisano ubiór o nazwie: ' .. data2.value)
			end)
		end)
	end
    end, function(data, menu)
        menu.close()
    end)
end


function OpenBossMenu(org, grade)
	if PlayerData.hiddenjob.grade >= grade then
		TriggerEvent('esx_society:openBossMenu', org, function(data, menu)
			menu.close()
		end, { showmoney = true, withdraw = true, deposit = true, wash = false, employees = true })
	else
		TriggerEvent('esx_society:openBossMenu', org, function(data, menu)
			menu.close()
		end, { showmoney = false, withdraw = false, deposit = true, wash = false, employees = false })
	end
end

local Blips = {}
local lastUsed = 0

RegisterNetEvent('neey_gwizdek:setBlip')
AddEventHandler('neey_gwizdek:setBlip', function(coords, job)
    for k, v in pairs(Config.Jobs) do
        if v == PlayerData.hiddenjob.name then
            if next(Blips) == nil then
                lastUsed = GetGameTimer() + Config.Cooldown * 1000
                local blip = AddBlipForCoord(coords.x, coords.y, coords.z)
                SetBlipPriority(blip, 4)
                SetBlipScale(blip, 0.9)
                SetBlipSprite(blip, 126)
                SetBlipColour(blip, 2)
                SetBlipAlpha(blip, 250)
                SetBlipAsShortRange(blip, true)

                BeginTextCommandSetBlipName("STRING")
                AddTextComponentString('# Gwizdek ('.. string.upper(job) .. ')')
                EndTextCommandSetBlipName(blip)
                ESX.ShowNotification('~r~ '..string.upper(job)..' użyła gwizdka! ~g~Kieruj się na GPS!')
                table.insert(Blips, { blip_data = blip, job = PlayerData.hiddenjob.name })
                Citizen.CreateThread(function()
                    local alpha = 250
                    while alpha > 0 and DoesBlipExist(blip) do
                        Citizen.Wait(Config.BlipTime * 500)
                        SetBlipAlpha(blip, alpha)
                        alpha = alpha - 25

                        if alpha == 0 then
                            RemoveBlip(blip)
                            for i, b in ipairs(Blips) do
                                if b.blip_data == blip then
                                    table.remove(Blips, i)
                                    return
                                end
                            end

                            break
                        end
                    end
                end)
            else
                for i, b in ipairs(Blips) do
                    if b.job == PlayerData.hiddenjob.name then
                        ESX.ShowNotification('Twoja  użyła już gwizdka!')
                        break 
                    else
                        lastUsed = GetGameTimer() + 300000
                        local blip = AddBlipForCoord(coords.x, coords.y, coords.z)
                        SetBlipPriority(blip, 4)
                        SetBlipScale(blip, 0.9)
                        SetBlipSprite(blip, 126)
                        SetBlipColour(blip, 2)
                        SetBlipAlpha(blip, 250)
                        SetBlipAsShortRange(blip, true)
                
                        BeginTextCommandSetBlipName("STRING")
                        AddTextComponentString('# Gwizdek ('.. string.upper(job) .. ')')
                        EndTextCommandSetBlipName(blip)
                
                        table.insert(Blips, { blip_data = blip, job = PlayerData.hiddenjob.name })
                        ESX.ShowNotification('~r~ '..string.upper(job)..' użyła gwizdka! ~g~Kieruj się na GPS!')
                        Citizen.CreateThread(function()
                            local alpha = 250
                            while alpha > 0 and DoesBlipExist(blip) do
                                Citizen.Wait(Config.BlipTime  * 500)
                                SetBlipAlpha(blip, alpha)
                                alpha = alpha - 5
                
                                if alpha == 0 then
                                    RemoveBlip(blip)
                                    for i, b in ipairs(Blips) do
                                        if b[i].blip_data == blip then
                                            table.remove(Blips, i)
                                            return
                                        end
                                    end
                                    break
                                end
                            end
                        end)
                        break
                    end
                end
            end
        end
    end
end)

local lastUsedKey = 0

RegisterCommand('gwizdek', function()
	if GetGameTimer() > lastUsed then
		if GetGameTimer() > lastUsedKey then
			local ped = PlayerPedId()
			local coords = GetEntityCoords(ped)
			TriggerServerEvent('neey_gwizdek:checkUse', coords)
			lastUsedKey = GetGameTimer() + 10000
		else
			ESX.ShowNotification('Nie tak szybko!')
		end
	else
		local time = lastUsed - GetGameTimer()
		ESX.ShowNotification('Odczekaj jeszcze: ' .. math.floor(time / 1000) .. 's!' )
	end
end)

