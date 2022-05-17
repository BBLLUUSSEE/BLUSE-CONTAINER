------------------------------CREDITS------------------------------
--------        Script made by Bluse and Invrokaaah        --------
------   Copyright 2021 BluseStudios. All rights reserved   -------
-------------------------------------------------------------------

Keys = {
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

local ESX = nil
local display = false

local blips = {

	{title="Gudang", colour=3, scale=0.5, id=368, x = 46.351737976074, y = -1749.3939208984, z = 29.637186050415},

	{title="Gudang", colour=3, scale=0.5,id=368, x = 2911.4760742188, y = 4469.3740234375, z = 48.102500915527},

	{title="Gudang", colour=3, scale=0.5, id=368, x = 94.071586608887, y = 6355.9428710938, z = 31.375860214233},
}

Citizen.CreateThread(function()
    Citizen.Wait(0)
    for _, info in pairs(blips) do
        info.blip = AddBlipForCoord(info.x, info.y, info.z)
        SetBlipSprite (info.blip, info.id)
        SetBlipDisplay(info.blip, 4)
        SetBlipScale  (info.blip, 0.7)
        SetBlipColour (info.blip, info.colour)
        SetBlipAsShortRange(info.blip, true)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString(info.title)
        EndTextCommandSetBlipName(info.blip)
    end
end)

function Draw3DText(x,y,z, text)
    local onScreen,_x,_y=World3dToScreen2d(x,y,z)
    local px,py,pz=table.unpack(GetGameplayCamCoords())
    SetTextScale(0.35, 0.35)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 215)
    SetTextEntry("STRING")
    SetTextCentre(1)
    AddTextComponentString(text)
    DrawText(_x,_y)
    local factor = (string.len(text)) / 370
    DrawRect(_x,_y+0.0125, 0.015+ factor, 0.03, 41, 11, 41, 68)
end

Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
	end
	while ESX.GetPlayerData().job == nil do
		Citizen.Wait(10)
	end
	ESX.PlayerData = ESX.GetPlayerData()


    playerIdent = ESX.GetPlayerData().identifier
end)

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
    ESX.PlayerData.job = job
end)

Citizen.CreateThread(function()

    while true do
		Citizen.Wait(0)
        local playerCoords = GetEntityCoords(GetPlayerPed(-1))
		local playerPed = PlayerPedId()
        local isClose = false
		
		for k, v in pairs (Config.Gudangs) do
			local gudang_name = v.gudang_name
            local gudang_loc = v.location
			local gudang_dist = GetDistanceBetweenCoords(playerCoords, gudang_loc.x, gudang_loc.y, gudang_loc.z, 1)
			
			if gudang_dist <= 1.0 then
				isClose = true
				--DrawMarker(Config.MarkerType, gudang_loc.x, gudang_loc.y, gudang_loc.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, Config.MarkerSize.x, Config.MarkerSize.y, Config.MarkerSize.z, Config.MarkerColor.r, Config.MarkerColor.g, Config.MarkerColor.b, 100, false, true, 2, false, nil, nil, false)
                Draw3DText(gudang_loc.x, gudang_loc.y, gudang_loc.z, "~y~Press ~r~[E] ~y~for open container")
                --DisplayHelpText('Premi E per comprare il container')
				if IsControlJustReleased(0, 38) then
					ESX.TriggerServerCallback('gudang:checkGudang', function(checkGudang)
						GudangMenu(k, checkGudang, gudang_name)
					end, k)
				end
			end
			
		end
        if not isClose then
            Citizen.Wait(300)
        end
	end
	
end)

function GudangMenu(k, hasGudang, gudangName)
	--If is your container then open ui2 = card2
	if hasGudang then
        SendNUIMessage({
            type = "ui2",
            display = true,
            SetNuiFocus(true, true)
        })
	end
	
	if not hasGudang then
        SendNUIMessage({
            type = "ui1",
            display = true,
            SetNuiFocus(true, true)
        })
	end
    
    RegisterNUICallback("buy", function(data)
        TriggerServerEvent('gudang:startRentingGudang', k, gudangName)
    end)

    RegisterNUICallback("open", function(data)
        TriggerEvent("inventory:openGudangInventory", gudangName, identifier)
    end)

    RegisterNUICallback("stop", function(data)
        TriggerServerEvent('gudang:stopRentingGudang', k, gudangName)
    end)
end

RegisterNUICallback("exit_ui1", function(data)
    SendNUIMessage({
        type = "ui1",
        display = false,
        SetNuiFocus(false, false)
    })
end)

RegisterNUICallback("exit_ui2", function(data)
    SendNUIMessage({
        type = "ui2",
        display = false,
        SetNuiFocus(false, false)
    })
end)

RegisterNUICallback("exit_ui3", function(data)
    SendNUIMessage({
        type = "ui3",
        display = false,
        SetNuiFocus(false, false)
    })
end)

RegisterNUICallback("open_ui3", function(data)
    SendNUIMessage({
        type = "ui3",
        display = true,
        SetNuiFocus(true, true)
    })
end)