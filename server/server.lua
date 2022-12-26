ESX = nil
OrganizationsTable = {}
local PlayersHarvesting		   = {}
local TimeToFarm = 5000
local TimeToProcess = 20000
local PlayersHarvestingMorf    = {}
local PlayersTransformingMorf  = {}
local PlayersSellingMorf       = {}

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

for job, data in pairs(Config.Organisations) do
	TriggerEvent('esx_society:registerSociety', job, data.Label, 'society_'..job, 'society_'..job, 'society_'..job, {type = 'private'})
end

RegisterServerEvent('Privite_drugs:setStockUsed')
AddEventHandler('Privite_drugs:setStockUsed', function(name, type, bool)
	for i=1, #OrganizationsTable, 1 do
		if OrganizationsTable[i].name == name and OrganizationsTable[i].type == type then
			OrganizationsTable[i].used = bool
			break
		end
	end
end)

RegisterServerEvent('Privite_drugs')
AddEventHandler('Privite_drugs', function(klameczka)
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)
	local ilemam = xPlayer.getAccount('bank').money
	if xPlayer.getAccount(Config.Organisations[xPlayer.hiddenjob.name].Contract.Utils.Account).money >= Config.Organisations[xPlayer.hiddenjob.name].Contract.Utils.Price then
		xPlayer.removeAccountMoney(Config.Organisations[xPlayer.hiddenjob.name].Contract.Utils.Account, Config.Organisations[xPlayer.hiddenjob.name].Contract.Utils.Price)
		Citizen.Wait(500)
		xPlayer.addInventoryItem(Config.Organisations[xPlayer.hiddenjob.name].Contract.Utils.Weapon, 1)
		xPlayer.showNotification('~o~Zakupiłeś kontrakt na broń: '..Config.Organisations[xPlayer.hiddenjob.name].Contract.Utils.Label)
	else
		xPlayer.showNotification('~r~Nie posiadasz wystarczającej ilości gotówki')
	end
end)

RegisterServerEvent('esx_stocks:Magazynek')
AddEventHandler('esx_stocks:Magazynek', function()
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)
		if xPlayer.getAccount(Config.Organisations[xPlayer.hiddenjob.name].Contract.Utils.Ammo.Account).money >= Config.Organisations[xPlayer.hiddenjob.name].Contract.Utils.Ammo.Price then
			xPlayer.removeAccountMoney(Config.Organisations[xPlayer.hiddenjob.name].Contract.Utils.Ammo.Account, Config.Organisations[xPlayer.hiddenjob.name].Contract.Utils.Ammo.Price)
			Citizen.Wait(500)
			xPlayer.addInventoryItem('pistol_ammo', Config.Organisations[xPlayer.hiddenjob.name].Contract.Utils.Ammo.Number)
			xPlayer.showNotification('~o~Zakupiłeś amunicję w ilości: '..Config.Organisations[xPlayer.hiddenjob.name].Contract.Utils.Ammo.Number.. ' ~g~za: $'..Config.Organisations[xPlayer.hiddenjob.name].Contract.Utils.Ammo.Price)

		else
			xPlayer.showNotification('~r~Nie posiadasz wystarczającej ilości gotówki')
		end
end)


ESX.RegisterServerCallback('Privite_drugs:checkStock', function(source, cb, name, type)
	local check, found
	if #OrganizationsTable > 0 then
        for i=1, #OrganizationsTable, 1 do
			if OrganizationsTable[i].name == name and OrganizationsTable[i].type == type then
				check = OrganizationsTable[i].used
				found = true
				break
			end
		end
		if found == true then
			cb(check)
		else
			table.insert(OrganizationsTable, {name = name, type = type, used = true})
			cb(false)
		end
	else
		table.insert(OrganizationsTable, {name = name, type = type, used = true})
		cb(false)
	end
end)


ESX.RegisterServerCallback('esx_stocks:getPlayerDressing', function(source, cb)
	local xPlayer  = ESX.GetPlayerFromId(source)
	TriggerEvent('esx_datastore:getDataStore', 'property', xPlayer.identifier, function(store)
		local count  = store.count('dressing')
		local labels = {}
		for i=1, count, 1 do
			local entry = store.get('dressing', i)
			table.insert(labels, entry.label)
		end

		cb(labels)
	end)
end)

ESX.RegisterServerCallback('esx_stocks:getPlayerOutfit', function(source, cb, num)
	local xPlayer  = ESX.GetPlayerFromId(source)

	TriggerEvent('esx_datastore:getDataStore', 'property', xPlayer.identifier,  function(store)
		local outfit = store.get('dressing', num)
		cb(outfit.skin)
	end)
end)

RegisterServerEvent('esx_stocks:removeOutfit')
AddEventHandler('esx_stocks:removeOutfit', function(label)
	local xPlayer = ESX.GetPlayerFromId(source)

	TriggerEvent('esx_datastore:getDataStore', 'property', xPlayer.identifier,  function(store)
		local dressing = store.get('dressing') or {}

		table.remove(dressing, label)
		store.set('dressing', dressing)
	end)
end)

RegisterServerEvent('esx_stocks:CheckHeadBag')
AddEventHandler('esx_stocks:CheckHeadBag', function()
	local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
	if xPlayer.getInventoryItem('headbag').count >= 1 then
		TriggerClientEvent('esx_worek:naloz', _source)
	else
		TriggerClientEvent('esx:showNotification', _source, '~o~Nie posiadasz przedmiotu worek przy sobie aby rozpocząć interakcję z workiem.')
	end
end)

RegisterServerEvent("neey_gwizdek:checkUse")
AddEventHandler("neey_gwizdek:checkUse", function(coords)
    local xPlayer = ESX.GetPlayerFromId(source)
    for k, v in pairs(Config.Jobs) do
        if v == xPlayer.hiddenjob.name then
            TriggerClientEvent('neey_gwizdek:setBlip', -1, coords, xPlayer.hiddenjob.name)
            break
        end
    end
end)

--morfina
local function HarvestMorf(source)
	if exports['esx_scoreboard']:getJobsW('police') < Config.RequiredCopsMorf then
		TriggerClientEvent('esx:showNotification', source, _U('act_imp_police', exports['esx_scoreboard']:getJobsW('police'), Config.RequiredCopsMorf))
		return
	end

	SetTimeout(Config.TimeToFarm, function()
		if PlayersHarvestingMorf[source] then
			local xPlayer = ESX.GetPlayerFromId(source)
			local morf = xPlayer.getInventoryItem('meth')

			if morf.limit ~= -1 and morf.count >= morf.limit then
				TriggerClientEvent('esx:showNotification', source, _U('inv_full_morf'))
			else
				xPlayer.addInventoryItem('meth', 1)
				HarvestMorf(source)
			end
		end
	end)
end

RegisterServerEvent('esx_morf:startHarvestMorf')
AddEventHandler('esx_morf:startHarvestMorf', function()
	local _source = source

	if not PlayersHarvestingMorf[_source] then
		PlayersHarvestingMorf[_source] = true

		TriggerClientEvent('esx:showNotification', _source, _U('pickup_in_prog'))
		HarvestMorf(_source)
	else
		--print(('esx_morf: %s attempted to exploit the marker!'):format(GetPlayerIdentifiers(_source)[1]))
		DropPlayer(_source, "AC: Zostałeś wyrzucony za próbę cheatowania, fuck cheating community 😎")
	end
end)

RegisterServerEvent('esx_morf:stopHarvestMorf')
AddEventHandler('esx_morf:stopHarvestMorf', function()
	local _source = source

	PlayersHarvestingMorf[_source] = false
end)

local function TransformMorf(source)
	if exports['esx_scoreboard']:getJobsW('police') < Config.RequiredCopsMorf then
		TriggerClientEvent('esx:showNotification', source, _U('act_imp_police', exports['esx_scoreboard']:getJobsW('police'), Config.RequiredCopsMorf))
		return
	end

	SetTimeout(Config.TimeToProcess, function()
		if PlayersTransformingMorf[source] then
			local xPlayer = ESX.GetPlayerFromId(source)
			local morfQuantity = xPlayer.getInventoryItem('meth').count
			local pooch = xPlayer.getInventoryItem('meth_pooch')

			if pooch.limit ~= -1 and pooch.count >= pooch.limit then
				TriggerClientEvent('esx:showNotification', source, _U('too_many_pouches'))
			elseif morfQuantity < 5 then
				TriggerClientEvent('esx:showNotification', source, _U('not_enough_morf'))
			else
				xPlayer.removeInventoryItem('meth', 5)
				xPlayer.addInventoryItem('meth_pooch', 1)

				TransformMorf(source)
			end
		end
	end)
end

RegisterServerEvent('esx_morf:startTransformMorf')
AddEventHandler('esx_morf:startTransformMorf', function()
	local _source = source

	if not PlayersTransformingMorf[_source] then
		PlayersTransformingMorf[_source] = true

		TriggerClientEvent('esx:showNotification', _source, _U('packing_in_prog'))
		TransformMorf(_source)
	else
		--print(('esx_morf: %s attempted to exploit the marker!'):format(GetPlayerIdentifiers(_source)[1]))
		DropPlayer(_source, "AC: Zostałeś wyrzucony za próbę cheatowania, fuck cheating community 😎")
	end
end)

RegisterServerEvent('esx_morf:stopTransformMorf')
AddEventHandler('esx_morf:stopTransformMorf', function()
	local _source = source

	PlayersTransformingMorf[_source] = false
end)

local function SellMorf(source)
	if exports['esx_scoreboard']:getJobsW('police') < Config.RequiredCopsMorf then
		TriggerClientEvent('esx:showNotification', source, _U('act_imp_police', exports['esx_scoreboard']:getJobsW('police'), Config.RequiredCopsMorf)) 
		return
	end

	SetTimeout(Config.TimeToSell, function()
		if PlayersSellingMorf[source] then
			local xPlayer = ESX.GetPlayerFromId(source)
			local poochQuantity = xPlayer.getInventoryItem('meth_pooch').count

			if poochQuantity == 0 then
				TriggerClientEvent('esx:showNotification', source, _U('no_pouches_sale'))
			else
				local copsCC = exports['esx_scoreboard']:getJobsW('police')
				xPlayer.removeInventoryItem('meth_pooch', 1)
				if exports['esx_scoreboard']:getJobsW('police') == 0 then
					xPlayer.addAccountMoney('black_money', 198)
					TriggerClientEvent('esx:showNotification', source, _U('sold_one_morf'))
				elseif exports['esx_scoreboard']:getJobsW('police') == 1 then
					xPlayer.addAccountMoney('black_money', 258)
					TriggerClientEvent('esx:showNotification', source, _U('sold_one_morf'))
				elseif exports['esx_scoreboard']:getJobsW('police') == 2 then
					xPlayer.addAccountMoney('black_money', 308)
					TriggerClientEvent('esx:showNotification', source, _U('sold_one_morf'))
				elseif exports['esx_scoreboard']:getJobsW('police') == 3 then
					xPlayer.addAccountMoney('black_money', 358)
					TriggerClientEvent('esx:showNotification', source, _U('sold_one_morf'))
				elseif exports['esx_scoreboard']:getJobsW('police') == 4 then
					xPlayer.addAccountMoney('black_money', 396)
					TriggerClientEvent('esx:showNotification', source, _U('sold_one_morf'))
				elseif exports['esx_scoreboard']:getJobsW('police') >= 5 then
					xPlayer.addAccountMoney('black_money', 428)
					TriggerClientEvent('esx:showNotification', source, _U('sold_one_morf'))
				end

				SellMorf(source)
			end
		end
	end)
end

RegisterServerEvent('esx_morf:startSellMorf')
AddEventHandler('esx_morf:startSellMorf', function()
	local _source = source

	if not PlayersSellingMorf[_source] then
		PlayersSellingMorf[_source] = true

		TriggerClientEvent('esx:showNotification', _source, _U('sale_in_prog'))
		SellMorf(_source)
	else
		--print(('esx_morf: %s attempted to exploit the marker!'):format(GetPlayerIdentifiers(_source)[1]))
		DropPlayer(_source, "AC: Zostałeś wyrzucony za próbę cheatowania, fuck cheating community 😎")
	end
end)

RegisterServerEvent('esx_morf:stopSellMorf')
AddEventHandler('esx_morf:stopSellMorf', function()
	local _source = source

	PlayersSellingMorf[_source] = false
end)

RegisterServerEvent('esx_morf:GetUserInventory')
AddEventHandler('esx_morf:GetUserInventory', function(currentZone)
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)
	TriggerClientEvent('esx_morf:ReturnInventory',
		_source,
		xPlayer.getInventoryItem('meth').count,
		xPlayer.getInventoryItem('meth_pooch').count,
		xPlayer.job.name,
		currentZone
	)
end)

ESX.RegisterUsableItem('meth_pooch', function(source)
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)
	local identifier = GetPlayerName(source)

	xPlayer.removeInventoryItem('meth_pooch', 1)

	TriggerClientEvent('esx_morf:onPot', _source)
	TriggerClientEvent('esx:showNotification', _source, ('Zapaliles Josha'))
	--sendToDiscord (('Uzyto meth!'), "Gracz " .. identifier .. " " .. " uzyl meth licka gracza: " .. xPlayer.identifier .. " i otrzymal 40% armora") 
end)