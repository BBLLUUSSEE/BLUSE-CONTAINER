------------------------------CREDITS------------------------------
--------        Script made by Bluse and Invrokaaah        --------
------   Copyright 2021 BluseStudios. All rights reserved   -------
-------------------------------------------------------------------

ESX = nil

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

ESX.RegisterServerCallback('gudang:checkGudang', function(source, cb, gudangId)
	local rdg = source
	local xPlayer = ESX.GetPlayerFromId(rdg)
	MySQL.Async.fetchAll('SELECT * FROM gudang WHERE gudangName = @gudangId AND identifier = @identifier', { ['@gudangId'] = gudangId, ['@identifier'] = xPlayer.identifier }, function(result) 
		if result[1] ~= nil then
			cb(true)
		else
			cb(false)
		end	
	end)
end)

RegisterServerEvent('gudang:startRentingGudang')
AddEventHandler('gudang:startRentingGudang', function(gudangId, gudangName)
	local rdg = source
	local xPlayer = ESX.GetPlayerFromId(rdg)
	MySQL.Async.fetchAll('SELECT * FROM gudang WHERE identifier = @identifier', { ['@identifier'] = xPlayer.identifier }, function(result)
		if result[1] == nil then
			if xPlayer.getMoney() >= Config.InitialRentPrice then
				MySQL.Async.execute('INSERT INTO gudang (identifier, gudangName) VALUES (@identifier, @gudangId)', {
					['@identifier'] = xPlayer.identifier,
					['@gudangId'] = gudangId,
				})
				xPlayer.removeMoney(Config.InitialRentPrice)
				--TriggerClientEvent('mythic_notify:client:SendAlert', source, { type = 'success', text = "You rent " ..gudangName.. " for $"..Config.InitialRentPrice.." dollars.", length = 5000 })
			else
				--TriggerClientEvent('mythic_notify:client:SendAlert', rdg, { type = 'error', text = "You need money for pay.", length = 5000 })
			end
		else
			--TriggerClientEvent('mythic_notify:client:SendAlert', rdg, { type = 'error', text = "you already own a container.", length = 5000 })
		end
	end)
end)

RegisterServerEvent('gudang:stopRentingGudang')
AddEventHandler('gudang:stopRentingGudang', function(gudangId, gudangName) 
	local rdg = source
	local xPlayer = ESX.GetPlayerFromId(rdg)
	MySQL.Async.fetchAll('SELECT * FROM gudang WHERE gudangName = @gudangId AND identifier = @identifier', { ['@gudangId'] = gudangId, ['@identifier'] = xPlayer.identifier }, function(result)
		if result[1] ~= nil then
			MySQL.Async.execute('DELETE from gudang WHERE gudangName = @gudangId AND identifier = @identifier', {
				['@gudangId'] = gudangId,
				['@identifier'] = xPlayer.identifier
			})
			--TriggerClientEvent('mythic_notify:client:SendAlert', rdg, { type = 'inform', text = "You stopped renting the container", length = 5000 })
		else
			--TriggerClientEvent('mythic_notify:client:SendAlert', rdg, { type = 'error', text = "You don't own this container.", length = 5000 })
		end
	end)
end)

function PayGudangRent(d, h, m)
	MySQL.Async.fetchAll('SELECT * FROM gudang', {}, function(result)
		for i=1, #result, 1 do
			local xPlayer = ESX.GetPlayerFromIdentifier(result[i].identifier)
			if xPlayer then
				xPlayer.removeAccountMoney('bank', Config.DailyRentPrice)
				--TriggerClientEvent('mythic_notify:client:SendAlert', xPlayer.source, { type = 'inform', text = "You pay $"..Config.DailyRentPrice.." for the container", length = 8000 })
			else
				MySQL.Sync.execute('UPDATE users SET bank = bank - @bank WHERE identifier = @identifier', { ['@bank'] = Config.DailyRentPrice, ['@identifier'] = result[i].identifier })
			end
		end
	end)
end

TriggerEvent('cron:runAt', 5, 10, PayGudangRent)


RegisterServerEvent('gudang:getItem')
AddEventHandler('gudang:getItem', function(owner, type, item, count)
	local _source      = source
	local xPlayer      = ESX.GetPlayerFromId(_source)
	local xPlayerOwner = ESX.GetPlayerFromIdentifier(owner)

	if type == 'item_standard' then

		local sourceItem = xPlayer.getInventoryItem(item)

		TriggerEvent('esx_addoninventory:getInventory', 'gudang', xPlayerOwner.identifier, function(inventory)
			local inventoryItem = inventory.getItem(item)

			-- is there enough in the property?
			if count > 0 and inventoryItem.count >= count then
			
				-- can the player carry the said amount of x item?
				if sourceItem.limit ~= -1 and (sourceItem.count + count) > sourceItem.limit then
					--TriggerClientEvent('mythic_notify:client:SendAlert', _source, { type = 'error', text = 'You cannot keep items of this type anymore.', length = 5000 })
				else
					inventory.removeItem(item, count)
					xPlayer.addInventoryItem(item, count)
					--TriggerClientEvent('mythic_notify:client:SendAlert', _source, { type = 'inform', text = 'You take '..count..'x '..inventoryItem.label..' from the container.', length = 5000 })
				end
			else
				--TriggerClientEvent('mythic_notify:client:SendAlert', _source, { type = 'error', text = 'You no longer have of this item in the container.', length = 5000 })
			end
		end)

	elseif type == 'item_account' then

		TriggerEvent('esx_addonaccount:getAccount', 'gudang', xPlayerOwner.identifier, function(account)
			local roomAccountMoney = account.money

			if roomAccountMoney >= count then
				account.removeMoney(count)
				xPlayer.addAccountMoney(item, count)
			else
				--TriggerClientEvent('mythic_notify:client:SendAlert', _source, { type = 'error', text = 'Valore non valido', length = 5000 })
			end
		end)

	elseif type == 'item_weapon' then

		TriggerEvent('esx_datastore:getDataStore', 'gudang', xPlayerOwner.identifier, function(store)
			local storeWeapons = store.get('weapons') or {}
			local weaponName   = nil
			local ammo         = nil

			for i=1, #storeWeapons, 1 do
				if storeWeapons[i].name == item then
					weaponName = storeWeapons[i].name
					ammo       = storeWeapons[i].ammo

					table.remove(storeWeapons, i)
					break
				end
			end

			store.set('weapons', storeWeapons)
			xPlayer.addWeapon(weaponName, ammo)
		end)

	end

end)

RegisterServerEvent('gudang:putItem')
AddEventHandler('gudang:putItem', function(owner, type, item, count)
	local _source      = source
	local xPlayer      = ESX.GetPlayerFromId(_source)
	local xPlayerOwner = ESX.GetPlayerFromIdentifier(owner)

	if type == 'item_standard' then

		local playerItemCount = xPlayer.getInventoryItem(item).count

		if playerItemCount >= count and count > 0 then
			TriggerEvent('esx_addoninventory:getInventory', 'gudang', xPlayerOwner.identifier, function(inventory)
				xPlayer.removeInventoryItem(item, count)
				inventory.addItem(item, count)
				--TriggerClientEvent('mythic_notify:client:SendAlert', _source, { type = 'inform', text = 'Store  '..count..'x '..inventory.getItem(item).label..' in the container.', length = 5000 })
			end)
		else
			--TriggerClientEvent('mythic_notify:client:SendAlert', _source, { type = 'error', text = 'Invalid quantity', length = 5000 })
		end

	elseif type == 'item_account' then

		local playerAccountMoney = xPlayer.getAccount(item).money

		if playerAccountMoney >= count and count > 0 then
			xPlayer.removeAccountMoney(item, count)

			TriggerEvent('esx_addonaccount:getAccount', 'gudang', xPlayerOwner.identifier, function(account)
				account.addMoney(count)
			end)
		else
			--TriggerClientEvent('mythic_notify:client:SendAlert', _source, { type = 'error', text = 'Invalid quantity', length = 5000 })
		end

	elseif type == 'item_weapon' then

		TriggerEvent('esx_datastore:getDataStore', 'gudang', xPlayerOwner.identifier, function(store)
			local storeWeapons = store.get('weapons') or {}

			table.insert(storeWeapons, {
				name = item,
				ammo = count
			})

			store.set('weapons', storeWeapons)
			xPlayer.removeWeapon(item)
		end)

	end

end)

ESX.RegisterServerCallback('gudang:getPropertyInventory', function(source, cb, owner, gudangName)
	local xPlayer    = ESX.GetPlayerFromIdentifier(owner)
	local blackMoney = 0
	local items      = {}
	local weapons    = {}

	TriggerEvent('esx_addonaccount:getAccount', 'gudang', xPlayer.identifier, function(account)
		blackMoney = account.money
	end)

	TriggerEvent('esx_addoninventory:getInventory', 'gudang', xPlayer.identifier, function(inventory)
		items = inventory.items
	end)

	TriggerEvent('esx_datastore:getDataStore', 'gudang', xPlayer.identifier, function(store)
		weapons = store.get('weapons') or {}
	end)

	cb({
		blackMoney = blackMoney,
		items      = items,
		weapons    = weapons,
		stash_name = gudangName
	})
end)